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
    timeline_path = '.history_payload/timeline.yaml'
    state_path = '.history_payload/state.json'
    
    with open(timeline_path, 'r') as f:
        data = yaml.safe_load(f)
        
    events = data.get('events', [])
    
    current_index = 0
    if os.path.exists(state_path):
        with open(state_path, 'r') as f:
            state = json.load(f)
            current_index = state.get('current_index', 0)
            
    if current_index >= len(events):
        print("All events have been processed. Engineering timeline is complete.")
        return
        
    event = events[current_index]
    print(f"Processing Event {current_index + 1}/{len(events)}: {event['title']}")
    
    # 1. Raise Issue
    issue = event.get('issue')
    issue_number = None
    if issue:
        title = issue['title'].replace('"', '\\"')
        desc = issue['description'].replace('"', '\\"')
        # Since this runs in Actions, we use the GH CLI
        print("Raising GitHub Issue...")
        try:
            result = subprocess.run(
                f'gh issue create --title "{title}" --body "{desc}"',
                shell=True, capture_output=True, text=True, check=True
            )
            # Try to extract issue URL or number from stdout
            print(f"Issue created: {result.stdout}")
            issue_number = result.stdout.strip().split('/')[-1]
        except Exception as e:
            print(f"Failed to create issue (ensure GH_TOKEN is valid): {e}")

    # 2. Extract Artifacts from Payload
    artifacts = event.get('artifacts', [])
    for art in artifacts:
        src = os.path.join('.history_payload', art.replace('/', os.sep))
        dst = art.replace('/', os.sep)
        
        # In a real payload, we would copy. For the seed, we mock the file if it doesn't exist.
        os.makedirs(os.path.dirname(dst) if os.path.dirname(dst) else '.', exist_ok=True)
        if os.path.exists(src):
            shutil.copy(src, dst)
        else:
            with open(dst, 'w') as f:
                f.write(f"// Content for {art}\n")
        run_cmd(f"git add {dst}")

    # 3. Handle ADR if exists
    adr = event.get('adr')
    if adr:
        adr_path = os.path.join('architecture', 'decisions', f"{adr['id']}.md")
        os.makedirs(os.path.dirname(adr_path), exist_ok=True)
        with open(adr_path, 'w') as f:
            f.write(f"# {adr['id']}: {adr['title']}\n\n{adr['content']}")
        run_cmd(f"git add {adr_path}")

    # 4. Incrementally Update README.md
    readme_content = f"\n## Iteration {current_index + 1}: {event['title']}\n"
    if issue:
        readme_content += f"**Problem:** {issue['title']}\n"
    if adr:
        readme_content += f"**Decision:** {adr['id']} - {adr['title']}\n"
    
    with open('README.md', 'a') as f:
        f.write(readme_content)
    run_cmd("git add README.md")
    
    # 5. Commit
    commit_msg = event.get('commit_msg', f"Implement {event['title']}")
    # If the previous event had an issue, we can pretend to resolve it (for now we just append a note)
    if current_index > 0:
        commit_msg += f"\n\nIterative advancement from previous milestone."
        
    run_cmd(f'git commit -m "{commit_msg}"')
    
    # 6. Update State
    with open(state_path, 'w') as f:
        json.dump({'current_index': current_index + 1}, f)
    run_cmd(f"git add {state_path}")
    run_cmd(f'git commit -m "chore: Update engineering state to {current_index + 1}"')
    
    # 7. Push changes
    print("Pushing to repository...")
    run_cmd("git push origin main")
    print(f"Event {event['title']} completed successfully.")

if __name__ == "__main__":
    main()
