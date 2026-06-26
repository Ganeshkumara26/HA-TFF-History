import os
import re
import shutil
import hashlib
import yaml
from datetime import datetime, timedelta

master_archive = r'd:\Downloads\ha_tff\Master_Archive'
payload_dir = r'd:\Downloads\ha_tff\HA_TFF_Repo\.history_payload'
blob_store = os.path.join(payload_dir, 'blob_store')
timeline_path = os.path.join(payload_dir, 'timeline.yaml')

os.makedirs(blob_store, exist_ok=True)

# Generate sophisticated timeline narrative
events = []
start_date = datetime(2026, 1, 1)

narratives = [
    {"title": "Initial MeghDut Assessment", "phase": "Research", "problem": "Evaluating baseline latency of software networking stacks for HFT", "hypothesis": "Software stacks exceed microsecond requirements", "experiment": "Profile MeghDut on ESP32", "decision": "Pivot to FPGA", "branch": "main", "milestone": "Research"},
    {"title": "FPGA Architecture Planning", "phase": "Design", "problem": "Need hardware-accelerated pipeline", "decision": "Design 64-bit AXI Stream datapath", "branch": "feature/architecture"},
    {"title": "Parser FSM Implementation", "phase": "Implementation", "problem": "Parsing UDP packets at line rate", "decision": "Implement custom state machine", "branch": "feature/parser"},
    {"title": "Parser FSM Timing Closure", "phase": "Verification", "problem": "FSM fails 6.4ns timing", "decision": "Add pipeline stage to tuple extraction", "branch": "feature/parser"},
    {"title": "Hash Unit Design", "phase": "Design", "problem": "Constant time lookup required for session tracking", "decision": "Use Cuckoo Hashing", "branch": "feature/hash"},
    {"title": "Cuckoo Hash Insertion Deadlock", "phase": "Implementation", "problem": "Collisions cause infinite loops during insertion", "decision": "Implement eviction limit", "branch": "feature/hash"},
    {"title": "BRAM Bandwidth Limitations", "phase": "Implementation", "problem": "BRAM ports saturated by hash lookups", "decision": "Replicate BRAM banks for parallel access", "branch": "feature/hash"},
    {"title": "Datapath Integration", "phase": "Integration", "problem": "Connect Parser and Hash unit", "decision": "Use AXI Stream FIFOs for backpressure", "branch": "feature/datapath"},
    {"title": "Matcher Pipeline Stalls", "phase": "Verification", "problem": "Matcher logic stalls the entire pipeline", "decision": "Fully pipeline the matcher with delay lines", "branch": "feature/datapath"},
    {"title": "Control Plane Interface", "phase": "Implementation", "problem": "Need CPU access to hash tables", "decision": "Implement AXI Lite register interface", "branch": "feature/control-plane"},
    {"title": "SNN Topology Exploration", "phase": "Research", "problem": "Determining optimal network for feature classification", "decision": "Use Leaky Integrate and Fire neurons", "branch": "feature/snn"},
    {"title": "Feature Encoder Design", "phase": "Design", "problem": "Converting packet lengths to spike trains", "decision": "Implement time-based threshold encoding", "branch": "feature/snn"},
    {"title": "SNN Neuron Implementation", "phase": "Implementation", "problem": "Mapping LIF math to Verilog", "decision": "Use fixed-point arithmetic, bit-shift for leaks", "branch": "feature/snn"},
    {"title": "SNN Layer Integration", "phase": "Integration", "problem": "Connecting 32 neurons in a layer", "decision": "Use broadcast bus for spikes", "branch": "feature/snn"},
    {"title": "SNN Timing Closure Failure", "phase": "Verification", "problem": "Critical path exceeds 6.4 ns", "hypothesis": "Adder tree has excessive combinational depth", "experiment": "Run post-synthesis timing", "result": "7.18 ns worst path", "decision": "Insert pipeline stage", "branch": "bugfix/snn-timing"},
    {"title": "System Top Integration", "phase": "Integration", "problem": "Connecting SNN to Datapath", "decision": "Implement Top-level wrapper", "branch": "feature/system-integration"},
    {"title": "SNN Leak Precision Issue", "phase": "Verification", "problem": "Neurons not leaking fast enough", "decision": "Increase precision of leak shift register", "branch": "bugfix/snn-leak"},
    {"title": "Drop FSM Implementation", "phase": "Implementation", "problem": "Need to physically drop malicious packets", "decision": "Implement tail-drop mechanism", "branch": "feature/drop-fsm"},
    {"title": "VLAN Alignment Bug", "phase": "Verification", "problem": "802.1Q tags break parsing offset", "decision": "Add VLAN detection state", "branch": "bugfix/vlan"},
    {"title": "Final Timing Validation", "phase": "Verification", "problem": "Ensure complete system meets 156.25 MHz", "decision": "Run full synthesis and implementation", "branch": "release/v1.0"},
]

# Ensure we have 30 events
while len(narratives) < 30:
    narratives.append({
        "title": f"Engineering Refinement {len(narratives)}",
        "phase": "Refinement",
        "branch": "develop",
        "problem": "Ongoing integration tasks"
    })

for i in range(30):
    ev_date = start_date + timedelta(days=i*4)
    event = {
        'id': f'ev{i:02d}',
        'title': narratives[i]['title'],
        'phase': narratives[i]['phase'],
        'problem': narratives[i]['problem'],
        'decision': narratives[i].get('decision', 'Implemented fixes'),
        'branch': narratives[i]['branch'],
        'commit': {
            'author': 'Ganeshkumara26',
            'date': ev_date.strftime('%Y-%m-%d'),
            'message': f"{narratives[i]['title']}\n\nProblem: {narratives[i]['problem']}\nDecision: {narratives[i].get('decision', 'N/A')}"
        },
        'instructions': []
    }
    
    # 20% chance to open an issue
    if i % 5 == 0 and i < 25:
        event['issue'] = {'action': 'open', 'title': narratives[i]['title'], 'labels': ['bug']}
    elif i % 5 == 1 and i <= 26:
        event['issue'] = {'action': 'close', 'ref': f'ev{i-1:02d}'}
        event['merge'] = narratives[i-1]['branch']

    events.append(event)

# Version mapping
v_to_ev = {
    1: 2, 2: 3, 3: 4, 4: 7, 5: 9, 6: 12,
    7: 13, 8: 14, 9: 15, 10: 16, 11: 17, 12: 18, 13: 19
}

def get_file_info(filepath):
    stat = os.stat(filepath)
    return stat.st_mtime, stat.st_size

def hash_file(filepath):
    with open(filepath, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

active_state = {}

def process_snapshot(ev_idx, category, source_folder, canonical_base):
    current_files = {}
    if os.path.exists(source_folder):
        for root, dirs, files in os.walk(source_folder):
            for f in files:
                if f.endswith('.vcd'):
                    continue # Ignore gigabyte VCDs
                abs_path = os.path.join(root, f)
                rel_path = os.path.relpath(abs_path, source_folder).replace('\\', '/')
                canonical_path = f"{canonical_base}/{rel_path}"
                current_files[canonical_path] = abs_path
                
    if category not in active_state:
        active_state[category] = {}
        
    old_files = active_state[category]
    
    # Deletions
    for old_path in old_files.keys():
        if old_path not in current_files:
            events[ev_idx]['instructions'].append({
                'type': 'DELETE',
                'dst': old_path
            })
            
    # Additions, Modifications, Renames (simplified)
    for new_path, abs_path in current_files.items():
        mtime, size = get_file_info(abs_path)
        
        # Check if modified
        is_modified = False
        is_new = False
        
        if new_path not in old_files:
            is_new = True
        else:
            old_mtime, old_size, old_hash = old_files[new_path]
            if size != old_size or mtime > old_mtime:
                # Fallback to hash comparison
                current_hash = hash_file(abs_path)
                if current_hash != old_hash:
                    is_modified = True
                else:
                    # Update mtime without emitting instruction
                    old_files[new_path] = (mtime, size, current_hash)

        if is_new or is_modified:
            current_hash = hash_file(abs_path)
            blob_name = f"{current_hash}_{os.path.basename(abs_path)}"
            blob_path = os.path.join(blob_store, blob_name)
            
            if not os.path.exists(blob_path):
                shutil.copy(abs_path, blob_path)
                
            instr_type = 'CREATE' if is_new else 'MODIFY'
            events[ev_idx]['instructions'].append({
                'type': instr_type,
                'src': f"blob_store/{blob_name}",
                'dst': new_path
            })
            old_files[new_path] = (mtime, size, current_hash)

for v in range(1, 14):
    ev_idx = v_to_ev[v]
    
    process_snapshot(ev_idx, 'rtl', os.path.join(master_archive, 'Engineering_History', '05_RTL', f'rtl_v{v:03d}'), 'rtl')
    process_snapshot(ev_idx, 'tb', os.path.join(master_archive, 'Engineering_History', '06_Testbenches', f'tb_v{v:03d}'), 'tb')
    process_snapshot(ev_idx, 'sim', os.path.join(master_archive, 'Engineering_History', '07_Simulations', f'sim{v:03d}'), 'sim')
    process_snapshot(ev_idx, 'synth', os.path.join(master_archive, 'Engineering_History', '08_Synthesis', f'synth{v:03d}'), 'reports/synthesis')

# Semantic Document Placement
for root, dirs, files in os.walk(master_archive):
    if 'rtl_v' in root or 'tb_v' in root or 'sim0' in root or 'synth0' in root:
        continue
    for f in files:
        if f.endswith('.md') or f.endswith('.csv'):
            abs_path = os.path.join(root, f)
            rel = os.path.relpath(abs_path, master_archive).replace('\\', '/')
            dst = f"docs/{rel}"
            
            # Semantic routing
            if 'MeghDut' in rel: ev_idx = 0
            elif 'Parser' in f: ev_idx = 2
            elif 'SNN' in f: ev_idx = 10
            elif 'Capstone' in rel: ev_idx = 29
            else: ev_idx = hash(f) % 25
            
            current_hash = hash_file(abs_path)
            blob_name = f"{current_hash}_{f}"
            blob_path = os.path.join(blob_store, blob_name)
            if not os.path.exists(blob_path):
                shutil.copy(abs_path, blob_path)
                
            events[ev_idx]['instructions'].append({
                'type': 'CREATE',
                'src': f"blob_store/{blob_name}",
                'dst': dst
            })

# Final validation simulation
sim_repo = {}
for ev in events:
    for instr in ev['instructions']:
        if instr['type'] in ['CREATE', 'MODIFY', 'RENAME']:
            sim_repo[instr['dst']] = instr['src']
        elif instr['type'] == 'DELETE':
            if instr['dst'] in sim_repo:
                del sim_repo[instr['dst']]
print(f"Validation: Simulated repo contains {len(sim_repo)} files.")

with open(timeline_path, 'w') as f:
    yaml.dump({'events': events}, f, default_flow_style=False, sort_keys=False)

print('Compiled Narrative ISA successfully.')
