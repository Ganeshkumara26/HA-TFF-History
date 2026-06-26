import os
import shutil
import yaml

master_archive = r'd:\Downloads\ha_tff\Master_Archive'
payload_dir = r'd:\Downloads\ha_tff\HA_TFF_Repo\.history_payload'
timeline_path = os.path.join(payload_dir, 'timeline.yaml')

print('Starting ingestion and flattening...')

# 1. Clean payload dir
shutil.rmtree(os.path.join(payload_dir, 'Master_Archive'), ignore_errors=True)
shutil.rmtree(os.path.join(payload_dir, 'flattened'), ignore_errors=True)

# Load timeline
with open(timeline_path, 'r') as f:
    data = yaml.safe_load(f)
    events = data.get('events', [])

# Clear all artifacts
for ev in events:
    ev['artifacts'] = []

# Mappings: folder string -> (target_event_idx, canonical_dir)
version_to_event = {
    'rtl_v001': (0, 'rtl'), 'rtl_v002': (2, 'rtl'), 'rtl_v003': (4, 'rtl'),
    'rtl_v004': (10, 'rtl'), 'rtl_v005': (12, 'rtl'), 'rtl_v006': (14, 'rtl'),
    'rtl_v007': (16, 'rtl'), 'rtl_v008': (17, 'rtl'), 'rtl_v009': (19, 'rtl'),
    'rtl_v010': (23, 'rtl'), 'rtl_v011': (25, 'rtl'), 'rtl_v012': (26, 'rtl'),
    'rtl_v013': (29, 'rtl'),
}

tb_to_event = {
    'tb_v001': (0, 'tb'), 'tb_v002': (2, 'tb'), 'tb_v003': (4, 'tb'),
    'tb_v004': (10, 'tb'), 'tb_v005': (12, 'tb'), 'tb_v006': (14, 'tb'),
    'tb_v007': (16, 'tb'), 'tb_v008': (17, 'tb'), 'tb_v009': (19, 'tb'),
    'tb_v010': (23, 'tb'), 'tb_v011': (25, 'tb'), 'tb_v012': (26, 'tb'),
    'tb_v013': (29, 'tb'),
}

sim_to_event = {
    'sim001': (0, 'sim'), 'sim002': (2, 'sim'), 'sim003': (4, 'sim'),
    'sim004': (10, 'sim'), 'sim005': (12, 'sim'), 'sim006': (14, 'sim'),
    'sim007': (16, 'sim'), 'sim008': (17, 'sim'), 'sim009': (19, 'sim'),
    'sim010': (23, 'sim'), 'sim011': (25, 'sim'), 'sim012': (26, 'sim'),
    'sim013': (29, 'sim'),
}

synth_to_event = {
    'synth001': (0, 'reports/synthesis'), 'synth002': (2, 'reports/synthesis'),
    'synth003': (4, 'reports/synthesis'), 'synth004': (10, 'reports/synthesis'),
    'synth005': (12, 'reports/synthesis'), 'synth006': (14, 'reports/synthesis'),
    'synth007': (16, 'reports/synthesis'), 'synth008': (17, 'reports/synthesis'),
    'synth009': (19, 'reports/synthesis'), 'synth010': (23, 'reports/synthesis'),
    'synth011': (25, 'reports/synthesis'), 'synth012': (26, 'reports/synthesis'),
    'synth013': (29, 'reports/synthesis'),
}

def determine_mapping(rel_path):
    for k, v in version_to_event.items():
        if k in rel_path: return v
    for k, v in tb_to_event.items():
        if k in rel_path: return v
    for k, v in sim_to_event.items():
        if k in rel_path: return v
    for k, v in synth_to_event.items():
        if k in rel_path: return v
        
    if 'Vol1_MeghDut_Learning' in rel_path: return (0, 'docs/meghdut')
    if 'Vol3_Capstone' in rel_path: return (29, 'docs/capstone')
    if '10_Design_Reviews' in rel_path: return (10, 'architecture/decisions')
    if '11_Lab_Notebook' in rel_path: return (15, 'docs/notebook')
    
    return (0, 'docs/general')

for root, dirs, files in os.walk(master_archive):
    for f in files:
        src_path = os.path.join(root, f)
        rel_path = os.path.relpath(src_path, master_archive).replace('\\', '/')
        
        target_idx, canonical_dir = determine_mapping(rel_path)
        
        payload_src_rel = f'flattened/ev{target_idx:02d}/{canonical_dir}/{f}'
        payload_src_abs = os.path.join(payload_dir, payload_src_rel.replace('/', os.sep))
        
        live_dst_rel = f'{canonical_dir}/{f}'
        
        os.makedirs(os.path.dirname(payload_src_abs), exist_ok=True)
        shutil.copy(src_path, payload_src_abs)
        
        events[target_idx]['artifacts'].append({
            'src': payload_src_rel,
            'dst': live_dst_rel
        })

with open(timeline_path, 'w') as f:
    yaml.dump({'events': events}, f, default_flow_style=False, sort_keys=False)

print('Successfully flattened Master_Archive and mapped to timeline.')
