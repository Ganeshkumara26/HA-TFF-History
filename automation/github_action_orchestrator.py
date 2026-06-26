import os
import json
import yaml
import subprocess
import shutil

def run_cmd(cmd):
    print(f"Running: {cmd}")
    try:
        subprocess.run(cmd, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e}")

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

def main():
    state_path = 'automation/state.json'
    timeline_path = '.history_payload/timeline.yaml'

    if os.path.exists(state_path):
        with open(state_path, 'r') as f:
            state = json.load(f)
    else:
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

    # Setup Commit Author and Date
    commit_data = event.get('commit', {})
    author = commit_data.get('author', 'Ganeshkumara26')
    date = commit_data.get('date', '2026-01-01')
    os.environ['GIT_AUTHOR_NAME'] = author
    os.environ['GIT_AUTHOR_EMAIL'] = 'hosakotaganeshkumara.me@gmail.com'
    os.environ['GIT_AUTHOR_DATE'] = f"{date}T12:00:00"
    os.environ['GIT_COMMITTER_NAME'] = author
    os.environ['GIT_COMMITTER_EMAIL'] = 'hosakotaganeshkumara.me@gmail.com'
    os.environ['GIT_COMMITTER_DATE'] = f"{date}T12:00:00"

    # 1. Handle Open Issue
    issue = event.get('issue')
    if issue and issue.get('action') == 'open':
        title = issue.get('title', event.get('title'))
        labels = ",".join(issue.get('labels', []))
        cmd = f'gh issue create --title "{title}" --body "Automated engineering issue track"'
        if labels:
            cmd += f' --label "{labels}"'
        run_cmd(cmd + ' > issue_out.txt')
        try:
            with open('issue_out.txt', 'r') as f:
                url = f.read().strip()
                issue_number = url.split('/')[-1]
                state['open_issues'][event['id']] = issue_number
                print(f"Opened issue #{issue_number}")
        except Exception as e:
            print("Failed to parse issue number.")
            
    # 2. Handle Branching
    branch = event.get('branch', 'main')
    run_cmd(f"git checkout -B {branch}")

    # 3. Execute Instructions (CREATE / MODIFY / RENAME / DELETE)
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
            run_cmd(f"git mv {old_dst} {new_dst}")
        elif inst['type'] == 'DELETE':
            dst = inst['dst']
            if os.path.exists(dst):
                os.remove(dst)
                run_cmd(f"git rm {dst}")

    # 4. Generate Engineering Notebook
    notebook_path = generate_notebook_entry(event)
    run_cmd(f"git add {notebook_path}")

    # 5. Commit
    commit_msg = commit_data.get('message', event.get('title'))
    
    if issue and issue.get('action') == 'close':
        ref_ev = issue.get('ref')
        issue_number = state['open_issues'].get(ref_ev)
        if issue_number:
            commit_msg += f"\n\nCloses #{issue_number}"

    res = subprocess.run("git status --porcelain", shell=True, capture_output=True, text=True)
    if res.stdout.strip():
        run_cmd(f'git commit -m "{commit_msg}"')

    # 6. Handle Merge
    merge = event.get('merge')
    if merge:
        run_cmd(f"git checkout {branch}")
        run_cmd(f"git merge {merge} --no-edit")

    # 7. Save State and Push
    state['current_index'] = current_index + 1
    with open(state_path, 'w') as f:
        json.dump(state, f)
        
    run_cmd(f"git add {state_path}")
    run_cmd(f'git commit -m "chore: Advance engineering state to {current_index + 1}"')
    
    run_cmd("git push origin --all")

if __name__ == "__main__":
    main()
