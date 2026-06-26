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

def main():
    state_path = 'automation/state.json'
    timeline_path = '.history_payload/timeline.yaml'
    
    # Ensure Git is configured for pushing
    run_cmd('git config --global user.name "Ganeshkumara26"')
    run_cmd('git config --global user.email "hosakotaganeshkumara.me@gmail.com"')

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

    # 1. Handle Open Issue
    issue = event.get('issue')
    if issue and issue.get('action') == 'open':
        title = issue.get('title', event.get('title'))
        run_cmd(f'gh issue create --title "{title}" --body "Automated engineering issue track" > issue_out.txt')
        try:
            with open('issue_out.txt', 'r') as f:
                url = f.read().strip()
                issue_number = url.split('/')[-1]
                state['open_issues'][event['id']] = issue_number
                print(f"Opened issue #{issue_number}")
        except Exception as e:
            print("Failed to parse issue number.")
            
    # 2. Handle Branching
    branch = event.get('branch', 'master')
    if branch != 'master':
        # Check if branch exists
        res = subprocess.run(f"git show-ref refs/heads/{branch}", shell=True)
        if res.returncode == 0:
            run_cmd(f"git checkout {branch}")
        else:
            run_cmd(f"git checkout -b {branch}")
    else:
        run_cmd("git checkout master")

    # 3. Execute Instructions (ADD / DELETE)
    instructions = event.get('instructions', [])
    for inst in instructions:
        if inst['type'] == 'ADD':
            src = os.path.join('.history_payload', inst['src'])
            dst = inst['dst']
            os.makedirs(os.path.dirname(dst) if os.path.dirname(dst) else '.', exist_ok=True)
            if os.path.exists(src):
                shutil.copy(src, dst)
            run_cmd(f"git add {dst}")
        elif inst['type'] == 'DELETE':
            dst = inst['dst']
            if os.path.exists(dst):
                os.remove(dst)
                run_cmd(f"git rm {dst}")

    # 4. Commit
    commit_msg = event.get('title')
    
    # Handle Close Issue via commit message
    if issue and issue.get('action') == 'close':
        ref_ev = issue.get('ref')
        issue_number = state['open_issues'].get(ref_ev)
        if issue_number:
            commit_msg += f"\n\nResolves #{issue_number}"

    # Only commit if there are changes
    res = subprocess.run("git status --porcelain", shell=True, capture_output=True, text=True)
    if res.stdout.strip():
        run_cmd(f'git commit -m "{commit_msg}"')

    # 5. Handle Merge
    merge = event.get('merge')
    if merge:
        run_cmd("git checkout master")
        run_cmd(f"git merge {merge} --no-edit")
        run_cmd(f"git branch -d {merge}")

    # 6. Save State and Push
    state['current_index'] = current_index + 1
    with open(state_path, 'w') as f:
        json.dump(state, f)
        
    run_cmd(f"git add {state_path}")
    run_cmd(f'git commit -m "chore: Advance engineering state to {current_index + 1}"')
    
    run_cmd("git push origin --all")

if __name__ == "__main__":
    main()
