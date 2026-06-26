import os
import re
import shutil
import hashlib
import yaml

master_archive = r'd:\Downloads\ha_tff\Master_Archive'
payload_dir = r'd:\Downloads\ha_tff\HA_TFF_Repo\.history_payload'
blob_store = os.path.join(payload_dir, 'blob_store')
timeline_path = os.path.join(payload_dir, 'timeline.yaml')

os.makedirs(blob_store, exist_ok=True)

# Generate timeline events
events = []
for i in range(30):
    events.append({
        'id': f'ev{i:02d}',
        'title': f'Engineering Event {i}',
        'instructions': []
    })

# Add Branching and Issues natively
events[2]['branch'] = 'feature/parser'
events[4]['merge'] = 'feature/parser'

events[19]['issue'] = {'action': 'open', 'title': 'SNN Timing Closure Failure'}
events[20]['issue'] = {'action': 'close', 'ref': 'ev19'}
events[20]['branch'] = 'bugfix/snn-timing'
events[23]['merge'] = 'bugfix/snn-timing'

# Mapping version numbers to timeline events
v_to_ev = {
    1: 0, 2: 2, 3: 4, 4: 10, 5: 12, 6: 14,
    7: 16, 8: 17, 9: 19, 10: 23, 11: 25, 12: 26, 13: 29
}

def get_file_hash(filepath):
    with open(filepath, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

def process_snapshot(ev_idx, category, source_folder, canonical_base):
    # Get all files in source_folder
    current_files = {}
    if os.path.exists(source_folder):
        for root, dirs, files in os.walk(source_folder):
            for f in files:
                abs_path = os.path.join(root, f)
                rel_path = os.path.relpath(abs_path, source_folder).replace('\\', '/')
                canonical_path = f"{canonical_base}/{rel_path}"
                current_files[canonical_path] = abs_path
                
    # Compare with active state
    if category not in active_state:
        active_state[category] = {}
        
    old_files = active_state[category]
    
    # Find Deletions
    for old_path in old_files.keys():
        if old_path not in current_files:
            events[ev_idx]['instructions'].append({
                'type': 'DELETE',
                'dst': old_path
            })
            
    # Find Additions / Modifications
    for new_path, abs_path in current_files.items():
        file_hash = get_file_hash(abs_path)
        blob_name = f"{file_hash}_{os.path.basename(abs_path)}"
        blob_path = os.path.join(blob_store, blob_name)
        
        # Copy to blob store if new
        if not os.path.exists(blob_path):
            shutil.copy(abs_path, blob_path)
            
        # Emit ADD instruction if it's new or modified
        if new_path not in old_files or old_files[new_path] != file_hash:
            events[ev_idx]['instructions'].append({
                'type': 'ADD',
                'src': f"blob_store/{blob_name}",
                'dst': new_path
            })
            
    # Update active state
    active_state[category] = {p: get_file_hash(f) for p, f in current_files.items()}


# Repository State Engine
active_state = {}

for v in range(1, 14):
    ev_idx = v_to_ev[v]
    
    # 1. RTL
    rtl_folder = os.path.join(master_archive, 'Engineering_History', '05_RTL', f'rtl_v{v:03d}')
    process_snapshot(ev_idx, 'rtl', rtl_folder, 'rtl')
    
    # 2. Testbenches
    tb_folder = os.path.join(master_archive, 'Engineering_History', '06_Testbenches', f'tb_v{v:03d}')
    process_snapshot(ev_idx, 'tb', tb_folder, 'tb')
    
    # 3. Simulations
    sim_folder = os.path.join(master_archive, 'Engineering_History', '07_Simulations', f'sim{v:03d}')
    process_snapshot(ev_idx, 'sim', sim_folder, 'sim')
    
    # 4. Synthesis
    synth_folder = os.path.join(master_archive, 'Engineering_History', '08_Synthesis', f'synth{v:03d}')
    process_snapshot(ev_idx, 'synth', synth_folder, 'reports/synthesis')

# Distribute Unversioned Documents
docs = []
for root, dirs, files in os.walk(master_archive):
    if 'rtl_v' in root or 'tb_v' in root or 'sim0' in root or 'synth0' in root:
        continue
    for f in files:
        if f.endswith('.md') or f.endswith('.csv'):
            docs.append(os.path.join(root, f))

# Spread docs across first 20 events
for i, doc_path in enumerate(docs):
    ev_idx = i % 20
    rel = os.path.relpath(doc_path, master_archive).replace('\\', '/')
    dst = f"docs/{rel}"
    
    file_hash = get_file_hash(doc_path)
    blob_name = f"{file_hash}_{os.path.basename(doc_path)}"
    blob_path = os.path.join(blob_store, blob_name)
    if not os.path.exists(blob_path):
        shutil.copy(doc_path, blob_path)
        
    events[ev_idx]['instructions'].append({
        'type': 'ADD',
        'src': f"blob_store/{blob_name}",
        'dst': dst
    })

# Write Timeline ISA
with open(timeline_path, 'w') as f:
    yaml.dump({'events': events}, f, default_flow_style=False, sort_keys=False)

print('Successfully compiled Master_Archive into Stateful Git Replay Engine ISA.')
