import re

def convert_to_hint_text(text):
    text = text.strip()
    # Replace <font> with <t> to be safe in CfgHints
    text = re.sub(r"<font([^>]*)>", r"<t\1>", text)
    
    # In CfgHints, 'size' is a multiplier (e.g. 1.0, 1.5, 2.0). 
    # In createDiaryRecord, size is absolute points (16, 18).
    # We must convert large integer sizes to reasonable multipliers to prevent "giga big" text.
    def size_repl(match):
        val = int(match.group(1))
        if val > 5:
            # e.g., 18 -> 1.5, 16 -> 1.2, 14 -> 1.1
            new_size = max(1.0, 1.0 + ((val - 14) * 0.1))
            return f"size='{new_size:.1f}'"
        return match.group(0)
    
    text = re.sub(r"size='(\d+)'", size_repl, text)
    text = re.sub(r'size="(\d+)"', size_repl, text)
    
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

# Reverse hints to emulate LIFO behavior of createDiaryRecord
hints.reverse()

out = []
out.append("class CfgHints {")
out.append("    class A3M_FieldManual {")
out.append('        displayName = "A3M Field Manual";')
out.append('        logicalOrder = 1;')

seen_titles = set()
order_index = 1
for title, body in hints:
    if title in seen_titles:
        continue
    seen_titles.add(title)
    
    class_name = re.sub(r'[^a-zA-Z0-9]', '', title)
    if not class_name:
        class_name = f"Entry_{order_index}"
    out.append(f"        class {class_name} {{")
    out.append(f'            displayName = "{title}";')
    out.append(f'            description = "{body}";')
    out.append(f'            logicalOrder = {order_index};')
    out.append("        };")
    order_index += 1

out.append("    };")
out.append("};")

with open("arma3mercenaries_2026.Altis/a3m_hints.hpp", "w", encoding="utf-8") as f:
    f.write("\n".join(out))

print("Generated a3m_hints.hpp")
