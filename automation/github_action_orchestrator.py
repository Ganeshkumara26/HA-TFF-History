import os
import json
import yaml
import subprocess
import shutil
import sys

def run_cmd(cmd, check=True):
    print(f"Running: {cmd}")
    try:
        res = subprocess.run(cmd, shell=True, check=check,
                             capture_output=True, text=True)
        return res.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e}")
        return None

def generate_notebook_entry(event):
    notebook_path = 'docs/Engineering_Notebook.md'
    os.makedirs('docs', exist_ok=True)

    date_str = event['commit'].get('date', 'Unknown Date')

    entry = f"\n## {date_str}: {event['title']}\n\n"
    if 'problem' in event:
        entry += f"**Problem:** {event['problem']}\n"
    if 'hypothesis' in event:
        entry += f"**Hypothesis:** {event['hypothesis']}\n"
    if 'experiment' in event:
        entry += f"**Experiment:** {event['experiment']}\n"
    if 'result' in event:
        entry += f"**Result:** {event['result']}\n"
    if 'decision' in event:
        entry += f"**Decision:** {event['decision']}\n"

    entry += "\n---\n"

    with open(notebook_path, 'a') as f:
        f.write(entry)

    return notebook_path

def load_state_from_git():
    """In CI the repo is freshly checked out and state.json may be on a past branch.
    Walk all refs looking for the latest committed state.json and recover position."""
    try:
        refs = run_cmd("git rev-list --all -- automation/state.json", check=False)
        if not refs:
            return None
        commits = [c for c in refs.splitlines() if c]
        if not commits:
            return None
        latest = commits[0]
        content = run_cmd(f"git show {latest}:automation/state.json", check=False)
        if content:
            return json.loads(content)
    except Exception as exc:
        print(f"State recovery from git failed: {exc}")
    return None

def git_issue_exists(title):
    """Return GitHub issue number if an open/closed issue with this title exists."""
    list_out = run_cmd(
        f'gh issue list --state all --search "{title}" --limit 1 --json number,title',
        check=False
    )
    if not list_out:
        return None
    try:
        import json as _json
        issues = _json.loads(list_out)
        if issues and issues[0].get('title', '').strip().lower() == title.strip().lower():
            return str(issues[0]['number'])
    except Exception:
        pass
    return None

def main():
    state_path = 'automation/state.json'
    timeline_path = '.history_payload/timeline.yaml'

    # ------------------------------------------------------------------
    # 1. Load state: prefer local file, fall back to git history for CI
    # ------------------------------------------------------------------
    state = None
    if os.path.exists(state_path):
        with open(state_path, 'r') as f:
            state = json.load(f)
    else:
        state = load_state_from_git()

    if state is None:
        state = {'current_index': 0, 'open_issues': {}}

    with open(timeline_path, 'r') as f:
        timeline = yaml.safe_load(f)

    events = timeline.get('events', [])
    current_index = state['current_index']

    if current_index >= len(events):
        print("All events processed. Engineering history complete!")
        return

    event = events[current_index]
    print(f"\n=== Executing Event {current_index}: {event.get('title')} ===")

    commit_data = event.get('commit', {})
    author = commit_data.get('author', 'Ganeshkumara26')
    date = commit_data.get('date', '2026-01-01')
    os.environ['GIT_AUTHOR_NAME'] = author
    os.environ['GIT_AUTHOR_EMAIL'] = 'hosakotaganeshkumara.me@gmail.com'
    os.environ['GIT_AUTHOR_DATE'] = f"{date}T12:00:00"
    os.environ['GIT_COMMITTER_NAME'] = author
    os.environ['GIT_COMMITTER_EMAIL'] = 'hosakotaganeshkumara.me@gmail.com'
    os.environ['GIT_COMMITTER_DATE'] = f"{date}T12:00:00"

    # ------------------------------------------------------------------
    # 2. Handle Issue lifecycle (idempotent)
    # ------------------------------------------------------------------
    issue = event.get('issue')
    if issue:
        action = issue.get('action')
        title = issue.get('title', event.get('title'))

        if action == 'open':
            existing_number = git_issue_exists(title)
            if existing_number:
                print(f"Issue already exists: #{existing_number}")
                state['open_issues'][event['id']] = existing_number
            else:
                labels = ",".join(issue.get('labels', []))
                cmd = f'gh issue create --title "{title}" --body "Automated engineering issue track"'
                if labels:
                    cmd += f' --label "{labels}"'
                out = run_cmd(cmd + ' > issue_out.txt', check=False)
                try:
                    with open('issue_out.txt', 'r') as f:
                        url = f.read().strip()
                        issue_number = url.split('/')[-1]
                        state['open_issues'][event['id']] = issue_number
                        print(f"Opened issue #{issue_number}")
                except Exception:
                    print("Failed to parse issue number.")

        elif action == 'close':
            ref_ev = issue.get('ref')
            issue_number = state['open_issues'].get(ref_ev)
            if issue_number:
                run_cmd(f'gh issue close {issue_number} --comment "Resolved by commit: {event.get(\"title\")}"', check=False)
                print(f"Closed issue #{issue_number}")
            else:
                print(f"No open issue found for ref {ref_ev}; skipping close.")

    # ------------------------------------------------------------------
    # 3. Handle branching
    # ------------------------------------------------------------------
    branch = event.get('branch', 'main')
    run_cmd(f"git checkout -B {branch}")

    # ------------------------------------------------------------------
    # 4. Execute file instructions
    # ------------------------------------------------------------------
    instructions = event.get('instructions', [])
    for inst in instructions:
        if inst['type'] in ['CREATE', 'MODIFY']:
            src = os.path.join('.history_payload', inst['src'])
            dst = inst['dst']
            os.makedirs(os.path.dirname(dst) if os.path.dirname(dst) else '.', exist_ok=True)
            if os.path.exists(src):
                shutil.copy(src, dst)
            run_cmd(f"git add {dst}")
        elif inst['type'] == 'RENAME':
            old_dst = inst['old_dst']
            new_dst = inst['dst']
            if os.path.exists(old_dst):
                run_cmd(f"git mv {old_dst} {new_dst}")
        elif inst['type'] == 'DELETE':
            dst = inst['dst']
            if os.path.exists(dst):
                os.remove(dst)
                run_cmd(f"git rm {dst}")

    # ------------------------------------------------------------------
    # 5. Engineering notebook
    # ------------------------------------------------------------------
    notebook_path = generate_notebook_entry(event)
    run_cmd(f"git add {notebook_path}")

    # ------------------------------------------------------------------
    # 6. Commit
    # ------------------------------------------------------------------
    commit_msg = commit_data.get('message', event.get('title'))

    if issue and issue.get('action') == 'close':
        ref_ev = issue.get('ref')
        issue_number = state['open_issues'].get(ref_ev)
        if issue_number:
            commit_msg += f"\n\nCloses #{issue_number}"

    res = subprocess.run("git status --porcelain", shell=True,
                         capture_output=True, text=True)
    if res.stdout.strip():
        run_cmd(f'git commit -m "{commit_msg}"')

    # ------------------------------------------------------------------
    # 7. Merge (only if the merge target branch exists locally)
    # ------------------------------------------------------------------
    merge = event.get('merge')
    if merge:
        # fetch remote branches so merge is possible
        run_cmd("git fetch origin", check=False)
        merge_exists = run_cmd(f"git show-ref --verify --quiet refs/heads/{merge}", check=False)
        if merge_exists is not None:
            run_cmd(f"git checkout {branch}")
            run_cmd(f"git merge {merge} --no-edit", check=False)
        else:
            print(f"Merge branch '{merge}' not found locally; skipping merge.")

    # ------------------------------------------------------------------
    # 8. Persist state and push
    # ------------------------------------------------------------------
    state['current_index'] = current_index + 1
    os.makedirs(os.path.dirname(state_path) if os.path.dirname(state_path) else '.', exist_ok=True)
    with open(state_path, 'w') as f:
        json.dump(state, f, indent=2)

    run_cmd(f"git add {state_path}")
    run_cmd(f'git commit -m "chore: Advance engineering state to {current_index + 1}"')

    run_cmd("git push origin --all")
    print(f"\nAdvanced state to index {state['current_index']}.")

if __name__ == "__main__":
    main()
