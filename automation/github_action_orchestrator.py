import os
import json
import yaml
import subprocess
import shutil
import sys

def run_cmd(cmd):
    print(f"Running: {cmd}")
    try:
        subprocess.run(cmd, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e}")
        sys.exit(1)

def main():
    timeline_path = '.history_payload/timeline.yaml'
    state_path = '.history_payload/state.json'
    
    with open(timeline_path, 'r') as f:
        data = yaml.safe_load(f)
        
    events = data.get('events', [])
    
    # Default State
    state = {
        'current_index': 0,
        'phase': 'RAISING_ISSUE',
        'active_issue_number': None
    }
    
    if os.path.exists(state_path):
        with open(state_path, 'r') as f:
            state.update(json.load(f))
            
    current_index = state['current_index']
    phase = state['phase']
    
    if current_index >= len(events):
        print("All events have been processed. Engineering timeline is complete.")
        return
        
    event = events[current_index]
    print(f"Processing Event {current_index + 1}/{len(events)}: {event['title']}")
    print(f"Current Phase: {phase}")
    
    if phase == 'RAISING_ISSUE':
        issue = event.get('issue')
        issue_number = None
        if issue:
            title = issue['title'].replace('"', '\\"')
            desc = issue['description'].replace('"', '\\"')
            print("Raising GitHub Issue...")
            try:
                result = subprocess.run(
                    f'gh issue create --title "{title}" --body "{desc}"',
                    shell=True, capture_output=True, text=True, check=True
                )
                print(f"Issue created: {result.stdout.strip()}")
                # gh issue create outputs the issue URL (e.g. https://github.com/user/repo/issues/12)
                issue_number = result.stdout.strip().split('/')[-1]
            except Exception as e:
                print(f"Failed to create issue (ensure GH_TOKEN is valid): {e}")
        else:
            print("No issue defined for this event.")
            
        # Update state to Phase 2
        state['phase'] = 'RESOLVING_ISSUE'
        state['active_issue_number'] = issue_number
        
        with open(state_path, 'w') as f:
            json.dump(state, f)
            
        run_cmd(f"git add {state_path}")
        run_cmd(f'git commit -m "chore: Opened Issue for Event {current_index + 1} (Waiting for next cycle)"')
        run_cmd("git push origin master")
        print(f"Phase 1 complete. Issue {issue_number} is now open. Stopping execution.")
        
    elif phase == 'RESOLVING_ISSUE':
        # 1. Extract Artifacts from Payload
        artifacts = event.get('artifacts', [])
        for art in artifacts:
            src = os.path.join('.history_payload', art.replace('/', os.sep))
            dst = art.replace('/', os.sep)
            os.makedirs(os.path.dirname(dst) if os.path.dirname(dst) else '.', exist_ok=True)
            if os.path.exists(src):
                shutil.copy(src, dst)
            else:
                with open(dst, 'w') as f:
                    f.write(f"// Content for {art}\n")
            run_cmd(f"git add {dst}")

        # 2. Handle ADR if exists
        adr = event.get('adr')
        if adr:
            adr_path = os.path.join('architecture', 'decisions', f"{adr['id']}.md")
            os.makedirs(os.path.dirname(adr_path), exist_ok=True)
            with open(adr_path, 'w') as f:
                f.write(f"# {adr['id']}: {adr['title']}\n\n{adr['content']}")
            run_cmd(f"git add {adr_path}")

        # 3. Incrementally Update README.md
        readme_content = f"\n## Iteration {current_index + 1}: {event['title']}\n"
        if event.get('issue'):
            readme_content += f"**Problem:** {event['issue']['title']}\n"
        if adr:
            readme_content += f"**Decision:** {adr['id']} - {adr['title']}\n"
        
        with open('README.md', 'a') as f:
            f.write(readme_content)
        run_cmd("git add README.md")
        
        # 4. Commit
        commit_msg = event.get('commit_msg', f"Implement {event['title']}")
        if state['active_issue_number']:
            commit_msg += f"\n\nResolves #{state['active_issue_number']}"
            
        run_cmd(f'git commit -m "{commit_msg}"')
        
        # 5. Update State for NEXT event
        state['current_index'] = current_index + 1
        state['phase'] = 'RAISING_ISSUE'
        state['active_issue_number'] = None
        
        with open(state_path, 'w') as f:
            json.dump(state, f)
            
        run_cmd(f"git add {state_path}")
        run_cmd(f'git commit -m "chore: Advance engineering state to {current_index + 1}"')
        run_cmd("git push origin master")
        print(f"Phase 2 complete. Event {event['title']} fully resolved.")

if __name__ == "__main__":
    main()
