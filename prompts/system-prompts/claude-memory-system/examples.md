# Memory Format Examples

## Description

Real-world examples of Claude's self-designed memory format from an actual project (Lantern - a network toolkit CLI). These demonstrate the compact, token-efficient encoding Claude chooses when optimizing for its own parsing.

**Note**: Your project's memory may look different. Claude adapts its format to each codebase.

---

## File: `_index` (Symbol Table)

The index file defines the memory format, symbols, and parsing rules.

```
_v:1
_t:2026-01-31T09:18:00Z
_fmt:claude_mem_v1

=files
core      #arch,patterns,deps,gotchas,decisions
direction #phases,roadmap,priorities,next
api       #cmds,types,contracts
session   #current_context,learned,questions

=symbols
_  metadata key
:  declaration
$  state
>  import/dependency
=  section
#  annotation
+  addition/positive
-  removal/negative
!  warning/gotcha
~  uncertainty/inference
?  question/unknown
@  decorator/flag
|  separator

=parse
lines independent,section headers =name
key:value pairs, | for lists inline
{} for nested structures when needed
[] for optional, () for required in cmds
```

### Key patterns:
- `_v`, `_t`, `_fmt` - Version, timestamp, format identifier
- `=section` - Section headers
- `#annotation` - Inline comments/descriptions
- Symbol table for consistent encoding across files

---

## File: `core` (Architecture & Decisions)

The core file captures project structure, dependencies, patterns, and gotchas.

```
_v:1
_t:2026-01-31T09:18:00Z
_h:3aca010

:P lantern-net|0.1.0|py>=3.11|MIT
:A Shubham Upadhyay
:D network toolkit CLI for devs|diagnose|transfer|control

$phase:3.8|P1:done|P2:done|P3:active|P4:plan|P5:plan
$focus:control_system,device_registry
$plat:macos:full|linux:stub|win:stub

>deps:typer<1|rich<14|qrcode<8|httpx<1|tomli-w<2
>deps.power:python-kasa>=0.6
>deps.dev:pytest|ruff|mypy

=arch
src/lantern/
  cli.py         #entrypoint,typer.Typer,register_all_tools
  config.py      #ConfigManager,AppConfig,DeviceConfig,TOML
  constants.py   #paths,defaults,platform_detect
  exceptions.py  #LanternError+CommandNotFound+PlatformNotSupported
  core/
    context.py   #Context@dataclass,json_output,console,get_context
    executor.py  #CommandRunner,async_subprocess
  platforms/
    base.py      #PlatformAdapter(ABC),async_methods
    factory.py   #get_adapter(),cached_singleton
    macos.py     #MacOSAdapter:networksetup,airport,scutil
  tools/
    __init__.py  #register_tool,register_all_tools
    qr.py        #lantern qr
    wifi/
      info.py    #lantern wifi info

=patterns
#cmd_reg:@register_tool decorator->_tool_registrations[]->register_all_tools(app)
#platform:PlatformAdapter.ABC->MacOS/Linux/Windows impl->get_adapter()singleton
#async:all platform ops async,tools use asyncio.run()
#output:Context.json_output->JSON or rich.Table
#config:~/.config/lantern/{config,devices}.toml

=gotchas
!airport cmd removed macOS Sequoia->fallback system_profiler
!wifi_password needs keychain access->may prompt
!scan needs network access,slow on large subnets
!device_cache in control.py is session-only,not persisted

=decisions
~CLI:typer|rationale:modern,type_hints,DX
~output:rich|rationale:tables,colors,sparklines
~config:TOML|rationale:human_readable
~async:required for network ops,subprocess
~safe_defaults:wifi scan requires --scan flag
```

### Key patterns:
- `_h:3aca010` - Git hash for change detection
- `:P`, `:A`, `:D` - Project, Author, Description
- `$state:value` - Current project state
- `>deps:` - Dependencies with version constraints
- `=arch` - File tree with inline purpose annotations
- `=gotchas` - Things that could surprise/break (prefixed with `!`)
- `=decisions` - Why choices were made (prefixed with `~` for inference)

---

## File: `api` (Commands & Types)

The API file documents commands, types, and interfaces.

```
_v:1
_t:2026-01-31T09:18:00Z

=cmds
lantern --version|-v
lantern interfaces [--json]
lantern router info [--json]
lantern dns info|flush [--json]
lantern wifi info|signal|scan [--scan] [--json]
lantern qr <text> [--invert] [--border N]
lantern share [--ssid S] [--password P] [--show-password]
lantern drop <file> [--port P] [--timeout T] [--no-qr]
lantern scan [--json]
lantern devices [list|add|remove|show|ping]
lantern ssh <device> [--user U]
lantern wake <mac_or_device> [--wait] [--then ssh]
lantern plug <device> on|off|toggle|status
lantern control discover|list|info|commands|run

=types:network.py
NetworkInterface{name,type:InterfaceType,status:InterfaceStatus,mac,ipv4,ipv6}
InterfaceType:ETHERNET|WIFI|LOOPBACK|BRIDGE|VIRTUAL|UNKNOWN
InterfaceStatus:UP|DOWN|UNKNOWN
WifiInfo{ssid,bssid,channel,frequency,rssi,noise,tx_rate,security}->signal_quality:int
WifiNetwork{ssid,bssid,channel,rssi,security,is_current}
RouterInfo{ip,interface,mac,hostname}
PingResult{host,ip,sent,received,loss%,min/avg/max/stddev_ms}->success:bool

=types:config.py
DeviceConfig{name,mac,ip,hostname,device_type,ssh_user,ssh_port,notes}
AppConfig{default_interface,json_output,color,verbose,ping_count}
ConfigManager{config_dir}
  +load_config()->AppConfig
  +save_config()
  +load_devices()->{name:DeviceConfig}
  +get/add/remove_device()

=platform_adapter_ABC
+name:str
+get_interfaces()->[NetworkInterface]
+get_default_interface()->NetworkInterface|None
+get_wifi_info()->WifiInfo|None
+scan_wifi()->[WifiNetwork]
+get_router_info()->RouterInfo|None
+ping(host,count,timeout)->PingResult
+get_arp_table()->[ArpEntry]
```

### Key patterns:
- Command syntax uses `[]` for optional, `<>` for required, `|` for alternatives
- Types use `{fields}` notation with type annotations after `:`
- Methods prefixed with `+`
- Return types after `->`

---

## File: `direction` (Roadmap & Priorities)

The direction file tracks phases, what's done, and what's next.

```
_v:1
_t:2026-01-31T09:18:00Z

:persona "Home Lab Developer"|macbook,rpis,nas,wfh/cafe

=phases
P1:Foundation[done]
  M1.1:skeleton[done]
  M1.2:platform_adapters[done:macos]
  M1.3:core_cmds[done]
  M1.4:wifi[done]
P2:Delight[done]
  M2.1:share,qr,whoami,port[done]
  M2.2:sonar[done]
  M2.3:drop,serve[done]
P3:LAN_Mastery[active]
  M3.1:config_system[done]
  M3.2:device_registry[done]
  M3.3:ssh_tools[done]
  M3.4:web_service_tools[partial]
  M3.5:wake[done]
  M3.6:smart_plugs[done:kasa]
  M3.7:file_shares[todo]
P4:Observability[plan]
  M4.1:watch,bw_monitor,uptime
  M4.2:TUI:textual,dashboard
P5:Pro_Tools[plan]
  M5.1:trace,ssl,probe,resolve

=priorities
HIGH:device_control_polish,more_adapters(sonos,bose,lgTV)
MED:linux_platform_impl,power_scheduling
LOW:windows,plugin_sdk

=next_likely
+control adapters for more devices
+services list/browse mDNS
+file shares discovery
+better error messages

=anti_patterns
-no nmap-style aggressive scanning
-no writing to system files without explicit ask
-no network config modification
-read-only by default
```

### Key patterns:
- `:persona` - Target user description
- `=phases` with `[done]`, `[active]`, `[partial]`, `[todo]`, `[plan]`
- Milestones nested under phases (M1.1, M1.2, etc.)
- `=priorities` with HIGH/MED/LOW
- `=anti_patterns` - What NOT to do (prefixed with `-`)

---

## File: `session` (Current Context)

The session file captures what was learned in the current/recent session.

```
_v:4
_t:2026-01-31
_sid:hook_setup

=context
$mode:normal
$task:complete
$status:idle

=learned_this_session
+SessionStart hook implemented to auto-load memory
+hook runs on all session types (no matcher = startup,resume,clear,compact)
+hook outputs mem files + git state as additionalContext
+mechanical enforcement > instruction compliance

=key_changes
.claude/hooks/load-memory.sh  #new:outputs mem/* and git hash
.claude/settings.json         #added SessionStart hook config

=user_preferences
+prefers mechanical solutions over behavioral instructions
+wants memory loaded on ALL session types, not just startup

=observations
~hooks inject content before Claude sees user message
~this removes dependency on Claude "remembering" to follow instructions
~still need manual checkpoint at session end (no hook for that)

=confidence
HIGH:hook setup,memory format,user expectations
```

### Key patterns:
- `_sid` - Session identifier/description
- `$mode`, `$task`, `$status` - Current state
- `=learned_this_session` - New knowledge (prefixed with `+`)
- `=key_changes` - Files modified with annotations
- `=user_preferences` - Discovered user preferences
- `=observations` - Inferences (prefixed with `~`)
- `=confidence` - Confidence levels for different knowledge areas

---

## Format Summary

| Symbol | Meaning | Example |
|--------|---------|---------|
| `_` | Metadata key | `_v:1`, `_t:2026-01-31` |
| `:` | Declaration | `:P lantern-net\|0.1.0` |
| `$` | State | `$phase:3.8` |
| `>` | Dependency | `>deps:typer<1\|rich<14` |
| `=` | Section | `=arch`, `=patterns` |
| `#` | Annotation | `#entrypoint,typer.Typer` |
| `+` | Addition/learned | `+hook implemented` |
| `-` | Removal/anti | `-no aggressive scanning` |
| `!` | Warning/gotcha | `!airport cmd removed` |
| `~` | Uncertainty | `~CLI:typer\|rationale:DX` |
| `?` | Unknown | `?integration method` |
| `\|` | Separator | `HIGH:x,y\|MED:z` |
| `{}` | Structure | `Type{field1,field2}` |
| `[]` | Optional/status | `[--json]`, `[done]` |
| `()` | Required/grouping | `<file>`, `(sonos,bose)` |

---

## Why This Format?

Claude chose this format because:

1. **Token efficiency** - Single characters for common concepts
2. **Line independence** - Each line is self-contained
3. **Hierarchical clarity** - Indentation + symbols show structure
4. **Fast parsing** - Consistent patterns, no ambiguity
5. **Semantic density** - Maximum meaning per token

The format is NOT meant to be human-edited. Trust Claude to maintain it.
