import re

def convert_to_hint_text(text):
    text = text.strip()
    # Replace <font> with <t> to be safe in CfgHints
    text = re.sub(r"<font([^>]*)>", r"<t\1>", text)
    text = text.replace("</font>", "</t>")
    # Strip actual line breaks since config files don't support multi-line strings
    text = text.replace('\n', ' ')
    text = text.replace('\r', '')
    # Escape quotes
    text = text.replace('"', '""')
    # Replace % with %% just in case it thinks it's a format arg
    text = text.replace('%', '%%')
    return text

def parse_sqf(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # match player createDiaryRecord ["subject", ["Title", "Content"]];
    pattern = re.compile(r'player createDiaryRecord\s*\[[^,]+,\s*\[\s*"([^"]+)"\s*,\s*"(.*?)"\s*\]\s*\]\s*;', re.DOTALL)
    
    entries = []
    for match in pattern.finditer(content):
        title = match.group(1)
        body = convert_to_hint_text(match.group(2))
        entries.append((title, body))
        
    return entries

hints = []
hints.extend(parse_sqf("arma3mercenaries_2026.Altis/arma3mercenaries/briefing/initBriefing.sqf"))
hints.extend(parse_sqf("arma3mercenaries_2026.Altis/briefing.sqf"))

out = []
out.append("class CfgHints {")
out.append("    class A3M_FieldManual {")
out.append('        displayName = "A3M Field Manual";')
out.append('        logicalOrder = 1;')

seen_titles = set()
for i, (title, body) in enumerate(hints):
    if title in seen_titles:
        continue
    seen_titles.add(title)
    
    class_name = re.sub(r'[^a-zA-Z0-9]', '', title)
    if not class_name:
        class_name = f"Entry_{i}"
    out.append(f"        class {class_name} {{")
    out.append(f'            displayName = "{title}";')
    out.append(f'            description = "{body}";')
    out.append("        };")

out.append("    };")
out.append("};")

with open("arma3mercenaries_2026.Altis/a3m_hints.hpp", "w", encoding="utf-8") as f:
    f.write("\n".join(out))

print("Generated a3m_hints.hpp")
