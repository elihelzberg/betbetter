"""Shared visual tokens and responsive dashboard styles."""
def:pub Styles -> JsxElement {
    return
        <style>
            {"""
    :root {
        --bg: #f7f8f4; --surface: #ffffff; --ink: #202d28;
        --muted: #727c75; --green: #245b45; --green-dark: #184633;
        --green-soft: #edf4e9; --lime: #d8eba7; --line: #e6e9e1;
        --radius: 14px; --sidebar: 224px;
        color-scheme: light;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        font-synthesis: none; text-rendering: optimizeLegibility;
    }
    * { box-sizing: border-box; }
    html { scroll-behavior: smooth; scroll-padding-top: 26px; }
    body { margin: 0; background: var(--bg); color: var(--ink); font-size: 14px; -webkit-font-smoothing: antialiased; }
    button, input, select, textarea { font: inherit; }
    button, a, summary, input, select, textarea { -webkit-tap-highlight-color: transparent; outline-offset: 4px; }
    button, summary { cursor: pointer; }
    button { transition: background .15s, color .15s, border-color .15s; }
    button:disabled { opacity: .45; cursor: default; }
    button:focus-visible, a:focus-visible, summary:focus-visible, [tabindex]:focus-visible { outline: 2px solid var(--green); }
    a { color: var(--green); text-decoration: none; }
    a:hover { color: var(--green-dark); }
    svg { display: block; flex-shrink: 0; }
    h1, h2, h3, p { margin-top: 0; }
    h2 { margin-bottom: 9px; font-size: 25px; line-height: 1.25; font-weight: 650; letter-spacing: -.9px; }
    h3 { margin-bottom: 12px; font-size: 15px; font-weight: 650; letter-spacing: -.2px; }
    .sr-only { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0,0,0,0); white-space: nowrap; border: 0; }
    .skip-link { position: fixed; z-index: 100; top: -80px; left: 16px; background: var(--green); color: white; padding: 14px 20px; border-radius: 8px; }
    .skip-link:focus { top: 12px; color: white; }
    .sidebar { width: var(--sidebar); position: fixed; inset: 0 auto 0 0; background: #fff; border-right: 1px solid var(--line); display: flex; flex-direction: column; padding: 32px 18px 22px; z-index: 30; }
    .wordmark { display: flex; align-items: center; gap: 9px; padding: 0 10px; color: var(--ink); font-size: 25px; letter-spacing: -1.1px; font-weight: 550; }
    .brand-symbol { width: 33px; height: 35px; border-radius: 8px; background: var(--green); color: var(--lime); display: grid; place-items: center; }
    .brand-emphasis { font-weight: 750; }.brand-period { color: var(--green); }
    .workspace-label { margin: 53px 14px 17px; color: #737c6d; font-size: 9px; letter-spacing: 1.5px; font-weight: 650; }
    .sidebar nav { display: grid; gap: 7px; }
    .nav-link { display: flex; align-items: center; gap: 12px; padding: 13px 14px; border-radius: 7px; color: #737b74; font-size: 13px; font-weight: 550; }
    .nav-link:hover { background: #f6f8f3; }.nav-link.active { background: var(--green-soft); color: var(--green); }
    .nav-count { margin-left: auto; padding: 3px 5px; border-radius: 4px; font-size: 9px; color: #5d7d47; background: #dceacb; }
    .sidebar-bottom { margin-top: auto; padding: 30px 5px 0; }
    .source-note { padding: 18px 14px; background: #f8f9f4; border: 1px solid #ebeee4; border-radius: 10px; }
    .source-icon { color: var(--green); display: block; margin-bottom: 14px; }
    .source-note strong { display: block; font-size: 11px; line-height: 1.5; }
    .source-note p { color: var(--muted); font-size: 11px; line-height: 1.7; margin: 9px 0 15px; }
    .source-note a { display: flex; align-items: center; gap: 8px; font-size: 11px; font-weight: 650; }
    .sidebar-foot { display: flex; align-items: center; gap: 8px; padding: 23px 12px 0; color: var(--muted); font-size: 11px; }
    .status-dot { display: inline-block; width: 6px; height: 6px; border-radius: 50%; background: #6e9c59; flex-shrink: 0; }
    .app-content { margin-left: var(--sidebar); min-width: 0; }
    .topbar { min-height: 77px; padding: 0 44px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid var(--line); background: #ffffffa8; gap: 20px; }
    .breadcrumb { display: flex; gap: 15px; align-items: center; font-size: 12px; color: #727b6e; }.breadcrumb strong { font-weight: 550; color: #526055; }
    .source-status { display: inline-flex; gap: 8px; align-items: center; color: #66745e; font-size: 11px; background: #f3f6ed; border: 1px solid #e5ebda; border-radius: 30px; padding: 8px 12px; }
    .shell { max-width: 1560px; margin: 0 auto; padding: 30px 44px 0; }
    .hero { display: flex; align-items: center; justify-content: space-between; gap: 38px; margin-bottom: 24px; }
    .eyebrow { display: flex; gap: 9px; align-items: center; color: var(--green); font-size: 9px; letter-spacing: 1.8px; font-weight: 700; }
    .eyebrow-line { width: 21px; height: 1px; background: var(--green); }
    h1 { font-size: clamp(39px, 3.25vw, 51px); line-height: 1.1; font-weight: 600; letter-spacing: -2.8px; margin: 15px 0 13px; }
    h1 span { color: var(--green); }
    .hero p { max-width: 480px; color: var(--muted); font-size: 13px; line-height: 1.85; margin-bottom: 0; }
    .hero-card { position: relative; overflow: hidden; display: flex; gap: 17px; align-items: flex-start; padding: 23px 25px; width: 335px; flex-shrink: 0; border: 1px solid #dce4cb; border-radius: var(--radius); background: #edf1e0; }
    .hero-card > div { z-index: 1; }
    .hero-card-icon { color: var(--green); background: #dce8c0; padding: 11px; border-radius: 11px; z-index: 1; }
    .hero-card-label { display: block; font-size: 8px; letter-spacing: 1.3px; font-weight: 700; color: #6d7b58; margin: 3px 0 14px; }
    .hero-card strong { display: block; font-size: 22px; font-weight: 550; line-height: 1.45; letter-spacing: -.65px; }
    .hero-card a { display: flex; align-items: center; gap: 9px; margin-top: 19px; font-size: 10px; font-weight: 650; }
    .hero-card-orbit { position: absolute; width: 165px; height: 165px; right: -81px; bottom: -83px; border: 1px solid #c6d3af; border-radius: 50%; box-shadow: 0 0 0 17px #edf1e0, 0 0 0 18px #d2ddbf, 0 0 0 35px #edf1e0, 0 0 0 36px #dce4ce; }
    .overview { display: grid; grid-template-columns: .9fr .95fr 1.15fr; background: var(--surface); border: 1px solid var(--line); border-radius: var(--radius); margin-bottom: 25px; padding: 21px 0; }
    .overview-stat { padding: 0 28px; border-right: 1px solid var(--line); }.overview-stat:last-child { border: 0; }
    .stat-label { display: flex; align-items: center; gap: 8px; font-size: 11px; color: #65705e; }
    .stat-label svg { color: #6c7c5b; }
    .overview-stat > strong { display: flex; gap: 10px; align-items: baseline; margin: 15px 0 8px; font-size: 28px; font-weight: 600; letter-spacing: -1px; font-variant-numeric: tabular-nums; }
    .overview-stat > strong span { color: #747f69; font-size: 10px; font-weight: 400; letter-spacing: 0; }
    .overview-stat > strong.date-stat { font-size: 24px; margin-top: 18px; margin-bottom: 9px; letter-spacing: -.65px; }
    .overview-stat > small { color: #727d68; font-size: 10px; }
    .panel { border: 1px solid var(--line); border-radius: var(--radius); background: var(--surface); min-width: 0; }
    .rankings-panel { overflow: visible; }
    .rankings-heading { padding: 22px 28px 20px; display: flex; justify-content: space-between; align-items: center; gap: 18px; }
    .section-kicker { display: inline-flex; align-items: center; gap: 8px; font-size: 9px; font-weight: 650; letter-spacing: 1.4px; color: #667557; margin-bottom: 11px; }
    .section-description { color: #6c7861; font-size: 12px; line-height: 1.8; margin-bottom: 0; }
    .primary, .secondary { display: inline-flex; align-items: center; justify-content: center; gap: 9px; min-height: 40px; border-radius: 7px; padding: 10px 16px; font-size: 11px; font-weight: 550; white-space: nowrap; }
    .primary { background: var(--green); color: #fff; border: 1px solid var(--green); }
    .primary:hover:not(:disabled) { background: var(--green-dark); border-color: var(--green-dark); }
    .secondary { background: #fff; color: #5d6758; border: 1px solid #e2e6da; }.secondary:hover:not(:disabled) { background: #f5f7ef; }
    .small-button { min-height: 31px; padding: 6px 12px; font-size: 10px; }
    .filters { border-block: 1px solid var(--line); padding: 21px 28px 18px; background: #fdfefb; }
    .filter-top { display: grid; grid-template-columns: 1fr 1.1fr auto; gap: 12px; }
    .search-field { display: flex; align-items: center; gap: 10px; color: #78856b; border: 1px solid #e1e6d8; border-radius: 7px; padding-left: 13px; background: #fff; min-width: 0; }
    input, select, textarea { color: var(--ink); background: white; border: 1px solid #dfe5d6; border-radius: 7px; min-width: 0; }
    input::placeholder, textarea::placeholder { color: #718161; }
    .search-field input { border: 0; background: transparent; width: 100%; height: 40px; padding: 10px 10px 10px 0; font-size: 11px; outline: 0; }
    .search-field:focus-within { outline: 2px solid #a4bea0; outline-offset: 1px; }
    .sort-field { display: flex; align-items: center; gap: 8px; padding-left: 12px; border: 1px solid #e1e6d8; border-radius: 7px; color: #6d7c5c; background: #fff; min-width: 0; }
    .sort-field > span { white-space: nowrap; font-size: 10px; }
    .sort-field select { width: 100%; font-size: 11px; font-weight: 550; border: 0; background: transparent; padding: 11px 18px 11px 0; min-height: 40px; }
    .filter-bottom { display: flex; align-items: center; justify-content: space-between; gap: 15px; padding-top: 17px; }
    .price-chips { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
    .price-chips > span { margin-right: 8px; font-size: 10px; color: #6d7d5d; }
    .price-chip { border: 1px solid #e6eadd; color: #5f714f; background: white; border-radius: 5px; min-height: 29px; padding: 5px 11px; font-size: 10px; }
    .price-chip:hover:not(:disabled) { border-color: #b6c7a3; }.price-chip.selected { color: var(--green); background: #eaf1df; border-color: #c7d8af; font-weight: 650; }
    .price-range { position: relative; flex-shrink: 0; }.price-range summary { list-style: none; display: flex; align-items: center; gap: 7px; color: #687b55; font-size: 10px; padding: 7px 0 7px 7px; }
    summary::-webkit-details-marker { display: none; }
    .range-inputs { position: absolute; z-index: 10; top: 37px; right: 0; padding: 16px; width: 280px; display: flex; align-items: end; gap: 10px; border: 1px solid var(--line); border-radius: 10px; box-shadow: 0 8px 24px #25332115; background: white; }
    .range-inputs label { display: grid; gap: 8px; font-size: 10px; color: var(--muted); }
    .range-inputs input { width: 70px; height: 34px; padding: 7px; }.range-inputs > span { align-self: center; margin-top: 16px; color: #9aa18f; }
    .results-caption { display: flex; justify-content: space-between; align-items: center; gap: 12px; padding: 15px 28px; font-size: 10px; color: #6b7c59; }
    .results-caption > span { display: inline-flex; gap: 7px; align-items: center; }.caption-separator { color: #bdc6af; padding: 0 2px; }
    .text-button { border: 0; background: transparent; color: #7b896c; font-size: 10px; padding: 3px 0; text-decoration: underline; text-underline-offset: 3px; }
    .table-scroll { overflow-x: auto; position: relative; }.rankings-results { overflow: hidden; border-radius: 0 0 var(--radius) var(--radius); }
    table { width: 100%; border-collapse: collapse; text-align: left; font-size: 12px; white-space: nowrap; font-variant-numeric: tabular-nums; }
    th { padding: 13px 15px; background: #f6f8f0; border-block: 1px solid var(--line); font-size: 10px; font-weight: 550; color: #61734f; }
    td { padding: 13px 15px; border-bottom: 1px solid #eff1e9; }.rankings-table tbody tr { transition: background .15s; }.rankings-table tbody tr:hover { background: #f9fbf5; }
    .rank-column, .rank-number { padding-left: 28px; width: 42px; }.rank-number { color: #70835e; font-size: 10px; }
    .game-name { display: flex; gap: 12px; align-items: center; text-align: left; background: none; border: 0; color: var(--ink); padding: 0; min-width: 170px; }
    .game-name strong { font-size: 12px; font-weight: 600; display: block; max-width: 205px; white-space: normal; line-height: 1.5; }
    .game-name small { display: block; color: #708161; font-size: 10px; margin-top: 5px; }
    .game-name:hover:not(:disabled) strong { color: var(--green); text-decoration: underline; text-underline-offset: 3px; }
    .game-tile { width: 37px; height: 40px; border: 1px solid #dde7cc; border-radius: 8px; display: grid; place-items: center; flex-shrink: 0; }
    .tile-0 { background: #eaf0dd; color: #788e4b; }.tile-1 { background: #f4eadb; color: #af8b59; border-color: #eaddc9; }.tile-2 { background: #e6ede5; color: #5d856e; border-color: #d9e4d6; }.tile-3 { background: #eeeaf3; color: #9283a1; border-color: #e4deeb; }
    .price-tag { display: inline-block; font-size: 11px; padding: 5px 7px; border-radius: 4px; background: #f5f6ef; color: #6d775e; }
    th.selected-column { color: var(--green); background: #eff5e6; }.metric-value { color: var(--green); font-weight: 650; font-size: 12px; }
    .numeric { color: #59654d; }.retention-value { color: #6b785c; font-size: 11px; }.retention-track { margin-top: 6px; height: 3px; width: 64px; border-radius: 4px; overflow: hidden; background: #e9efdf; }.retention-track span { display: block; height: 100%; background: #99b674; border-radius: inherit; }
    .icon-button { display: inline-flex; align-items: center; justify-content: center; background: white; border: 1px solid var(--line); border-radius: 7px; width: 34px; height: 34px; color: #7e8a6e; }.icon-button:hover:not(:disabled) { background: #f1f5e9; }.row-open { border: 0; background: transparent; width: 25px; }
    .table-footer { display: flex; justify-content: space-between; gap: 15px; align-items: center; padding: 17px 28px; background: #fdfefb; }.table-footer p { margin: 0; color: #6d8058; font-size: 10px; }
    .pagination { display: inline-flex; gap: 12px; align-items: center; }.pagination > span { color: #6b7c5a; font-size: 10px; }
    .loading-state { display: flex; align-items: center; justify-content: center; gap: 11px; padding: 65px 20px; color: #7b876d; font-size: 12px; }
    .loader { width: 17px; height: 17px; border: 2px solid #e5ecdb; border-top-color: var(--green); border-radius: 50%; animation: spin .8s linear infinite; }
    @keyframes spin { to { transform: rotate(360deg); } }
    .empty-state { padding: 42px 24px; text-align: center; color: #6a7b58; }.empty-state > svg { margin: 0 auto 14px; }.empty-state h3 { color: #657455; margin-bottom: 8px; }.empty-state p { margin-bottom: 0; font-size: 12px; }
    .data-note { display: flex; gap: 10px; margin: 18px 3px 31px; color: #6b7c58; align-items: flex-start; }.data-note svg { margin-top: 2px; }.data-note p { font-size: 10px; line-height: 1.9; margin: 0; }.data-note a { color: #6a8154; display: inline-flex; gap: 5px; align-items: center; margin-left: 3px; font-weight: 550; }
    .bottom-grid { display: grid; grid-template-columns: 1.05fr 1fr; gap: 24px; margin-bottom: 35px; align-items: start; }
    .question-panel, .method { padding: 27px 28px; }.question-panel h2, .method h2 { max-width: 350px; font-size: 25px; line-height: 1.4; margin-top: 2px; margin-bottom: 10px; }
    .section-heading { display: flex; justify-content: space-between; align-items: center; gap: 16px; margin-bottom: 14px; }.section-heading .section-kicker { margin: 0; }
    .tag { display: inline-flex; align-items: center; padding: 5px 8px; border-radius: 5px; background: #f2f5ea; border: 1px solid #e5ebd9; color: #657f48; font-size: 9px; white-space: nowrap; }
    .question-form { border: 1px solid #dfe7d3; border-radius: 9px; margin-top: 23px; background: #fcfdf9; overflow: hidden; }.question-form:focus-within { outline: 2px solid #b5c7a7; outline-offset: 2px; }
    .question-form textarea { width: 100%; min-height: 96px; padding: 15px; border: 0; resize: vertical; background: transparent; font-size: 12px; line-height: 1.7; outline: 0; display: block; }
    .question-actions { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 10px 12px; border-top: 1px solid #edf0e6; }.question-actions > span { color: #718461; font-size: 9px; }.question-actions .primary { min-height: 33px; padding: 8px 12px; font-size: 10px; }
    .suggestions { display: flex; flex-wrap: wrap; gap: 7px; margin: 14px 0 22px; }.suggestions > span { width: 100%; font-size: 9px; color: #6c8059; margin-bottom: 2px; }.suggestions button { background: #fafbf7; border: 1px solid #e8edde; border-radius: 5px; padding: 6px 8px; color: #62784f; font-size: 9px; }.suggestions button:hover:not(:disabled) { background: #edf3e3; color: var(--green); }
    .ai-disclaimer { border-top: 1px solid var(--line); padding-top: 15px; }.ai-disclaimer summary { color: #697d54; display: flex; align-items: center; gap: 7px; font-size: 9px; list-style: none; }.ai-disclaimer p { font-size: 10px; color: #859476; line-height: 1.9; margin: 12px 0 0; }
    .answer { margin-bottom: 20px; padding: 17px; border: 1px solid #dce8cc; background: #f5f9ee; border-radius: 8px; }.answer > p { color: #6c7e59; font-size: 12px; line-height: 1.8; margin: 11px 0; }.answer-mode { display: inline-block; color: var(--green); font-size: 9px; font-weight: 650; text-transform: uppercase; letter-spacing: 1px; }.answer ol { list-style: none; padding: 0; margin: 8px 0 0; }.answer-game { display: flex; align-items: center; gap: 10px; justify-content: space-between; border: 0; border-top: 1px solid #e1ead5; padding: 13px 0; width: 100%; background: transparent; text-align: left; color: #536e3e; font-size: 10px; }.answer-game > span:first-child { flex: 1; }.answer-game small { display: block; color: #698152; font-size: 9px; margin-top: 5px; }.answer-game > span:nth-child(2) { text-align: right; }.answer-game:hover:not(:disabled) strong { text-decoration: underline; }
    .method > .section-kicker { margin-bottom: 17px; }.method > .section-description { margin-bottom: 20px; }
    .method details { border-top: 1px solid var(--line); }.method summary { display: flex; align-items: center; gap: 11px; list-style: none; color: #5a6e47; font-size: 11px; font-weight: 550; padding: 17px 0; }.method summary > svg { margin-left: auto; transition: transform .2s; }.method details[open] summary > svg { transform: rotate(90deg); }.note-number { color: #71865b; font-size: 9px; }.note-body { padding: 0 0 14px 25px; }.note-body p { color: #677b53; font-size: 11px; line-height: 1.85; margin-bottom: 11px; }.note-body a { display: inline-flex; align-items: center; gap: 6px; font-size: 11px; }.formula { padding: 13px; border: 1px solid #e8eddf; background: #f8faf3; color: #7c8c69; font-family: ui-monospace, monospace; font-size: 10px; line-height: 1.8; border-radius: 6px; margin-bottom: 12px; }
    .research-principle { display: flex; align-items: center; gap: 12px; margin-top: 14px; padding: 15px; background: #f5f8ed; border-radius: 7px; color: #7f9365; font-size: 10px; line-height: 1.8; }.research-principle strong { color: #5d7846; font-weight: 550; }
    .details-panel { padding: 28px; margin-bottom: 30px; scroll-margin-top: 25px; animation: reveal .25s ease-out; }.details-heading { display: flex; align-items: flex-start; gap: 20px; justify-content: space-between; margin-bottom: 23px; }.details-heading h2 { font-size: 30px; }.details-heading p { color: #859376; font-size: 11px; margin: 8px 0 0; }.detail-actions { display: flex; gap: 10px; align-items: center; }.detail-stats { display: grid; grid-template-columns: repeat(4, 1fr); border: 1px solid var(--line); border-radius: 9px; background: #fafcf6; padding: 21px 0; margin-bottom: 28px; }.detail-stats > div { padding: 0 18px; border-right: 1px solid var(--line); }.detail-stats > div:last-child { border: 0; }.detail-stats small { display: block; color: #637a4c; font-size: 9px; }.detail-stats strong { display: block; font-size: 24px; font-weight: 550; letter-spacing: -.8px; color: #3b5d2d; margin: 12px 0 7px; }.detail-stats span { font-size: 9px; color: #6b8255; }.detail-columns { display: grid; grid-template-columns: 1.4fr 1fr; gap: 25px; }.subsection-heading { display: flex; align-items: center; gap: 14px; justify-content: space-between; margin-bottom: 15px; }.subsection-heading h3 { margin: 0; }.model-notes { padding: 19px; border: 1px solid #e5ebda; background: #fafcf6; border-radius: 9px; }.model-notes dl { margin: 17px 0; }.model-notes dl > div { display: flex; justify-content: space-between; gap: 12px; padding: 8px 0; border-bottom: 1px solid #eaf0e1; font-size: 10px; }.model-notes dt { color: #6a8054; }.model-notes dd { margin: 0; color: #5d7747; text-align: right; }.model-notes p { font-size: 10px; line-height: 1.9; color: #6a8054; margin: 12px 0 0; }.change-strip { display: flex; align-items: center; gap: 27px; border-block: 1px solid var(--line); margin: 26px 0; padding: 18px 0; }.change-strip > span { color: #859875; font-size: 10px; margin-right: auto; }.change-strip small { color: #6d8654; display: block; font-size: 9px; margin-bottom: 5px; }.change-strip strong { color: #54763b; font-size: 13px; font-weight: 550; }.source-dates { display: flex; gap: 18px; flex-wrap: wrap; font-size: 9px; color: #6b8058; margin-top: 23px; }.muted { color: #6b8055; font-size: 10px; line-height: 1.8; margin: 5px 0 0; }
    .history-pagination { display: flex; align-items: center; justify-content: space-between; gap: 15px; margin-top: 17px; }.history-pagination > span { font-size: 10px; color: #6b8055; }
    .supporting-metrics { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; border-block: 1px solid var(--line); margin-top: 25px; padding: 20px 0; }.supporting-metrics span { display: block; color: #6a7e55; font-size: 10px; margin-bottom: 8px; }.supporting-metrics strong { color: #38592a; font-size: 17px; font-weight: 550; }.supporting-metrics + .change-strip { border-top: 0; margin-top: 0; }
    .error { padding: 13px 16px; background: #fff6ed; border: 1px solid #f1d9ba; color: #9a6131; font-size: 11px; line-height: 1.7; border-radius: 7px; }.rankings-error { margin: 0 28px 16px; }.error .text-button { color: #9a6131; margin-left: 12px; }
    footer { border-top: 1px solid var(--line); padding: 24px 0 26px; display: flex; gap: 18px; align-items: center; color: #6e805d; font-size: 9px; }.footer-brand { font-size: 17px; font-weight: 650; letter-spacing: -.7px; color: #728565; }.footer-brand span { color: #9ebf71; }footer p { margin: 0; }footer > span { margin-left: auto; display: flex; align-items: center; gap: 8px; }
    @keyframes reveal { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }
    @media (min-width: 1600px) { .shell { padding-inline: 55px; }.hero { padding-block: 10px; }.hero p { max-width: 520px; }.hero-card { width: 365px; }table { font-size: 12px; }.game-name strong { font-size: 12px; }th { font-size: 10px; }td { padding-block: 15px; } }
    @media (max-width: 1200px) { :root { --sidebar: 200px; }.sidebar { padding-inline: 13px; }.wordmark { font-size: 23px; }.shell { padding: 32px 26px 0; }.topbar { padding-inline: 26px; }.hero-card { width: 290px; padding: 23px 20px; gap: 12px; }.hero-card-label { font-size: 7px; }.hero-card strong { font-size: 21px; }.hero-card-icon { padding: 8px; }.overview-stat { padding-inline: 22px; }.overview-stat > strong { font-size: 25px; }.overview-stat > strong.date-stat { font-size: 22px; }.filter-top { grid-template-columns: 1fr 1fr; }.filter-submit { grid-column: 2; grid-row: 2; justify-self: end; }.filter-bottom { margin-top: -45px; padding-top: 0; padding-right: 142px; align-items: start; flex-direction: column; gap: 4px; }.price-chips > span { display: none; }.bottom-grid { gap: 19px; }.question-panel, .method { padding: 25px 22px; }.section-kicker { font-size: 8px; }.detail-columns { grid-template-columns: 1fr; }.model-notes dl { display: grid; grid-template-columns: 1fr 1fr; gap: 0 22px; }.detail-stats strong { font-size: 21px; } }
    @media (max-width: 980px) { :root { --sidebar: 176px; }.sidebar { padding-inline: 10px; }.wordmark { padding: 0 5px; font-size: 21px; gap: 6px; }.brand-symbol { width: 29px; height: 31px; }.nav-link { padding-inline: 10px; gap: 9px; font-size: 11px; }.nav-count { display: none; }.workspace-label { font-size: 8px; margin-left: 10px; }.source-note { padding-inline: 11px; }.source-note strong { font-size: 10px; }.source-note p { font-size: 10px; }.hero { gap: 23px; }.hero-card { display: none; }h1 { font-size: 48px; }.hero p { max-width: 510px; }.overview { grid-template-columns: 1fr 1fr 1.15fr; }.overview-stat { padding-inline: 16px; }.overview-stat > strong { flex-wrap: wrap; gap: 3px; font-size: 25px; }.overview-stat > strong span { width: 100%; }.overview-stat > strong.date-stat { font-size: 21px; line-height: 1.35; margin-block: 14px 8px; }.stat-label { font-size: 9px; }.overview-stat > small { font-size: 9px; }.bottom-grid { grid-template-columns: 1fr; }.question-panel h2, .method h2 { max-width: none; }.detail-stats { grid-template-columns: 1fr 1fr; gap: 23px 0; }.detail-stats > div:nth-child(2) { border: 0; }.rankings-heading { padding: 23px; }.rankings-heading > .secondary { padding-inline: 10px; font-size: 10px; }.rankings-heading h2 { font-size: 23px; }.filters { padding-inline: 23px; }.filter-top { grid-template-columns: 1fr; }.filter-submit { grid-column: 1; grid-row: 3; }.filter-bottom { padding-right: 130px; }.price-chips { gap: 4px; }.price-chip { padding-inline: 9px; }footer > span { display: none; } }
    @media (max-width: 700px) { .history-pagination { flex-direction: column; align-items: flex-start; }.history-pagination .pagination { align-self: flex-end; }.supporting-metrics { grid-template-columns: 1fr 1fr; gap: 20px; } :root { --sidebar: 0px; }html { scroll-padding-top: 80px; }.sidebar { position: sticky; top: 0; width: 100%; height: auto; padding: 13px 18px 0; border-right: 0; border-bottom: 1px solid var(--line); background: #fff; }.wordmark { font-size: 23px; padding: 0; }.brand-symbol { width: 30px; height: 31px; }.workspace-label, .sidebar-bottom { display: none; }.sidebar nav { display: flex; gap: 7px; margin-top: 13px; }.nav-link { flex: 1; justify-content: center; border-radius: 6px 6px 0 0; padding: 12px 8px; font-size: 10px; gap: 7px; }.nav-link svg { width: 16px; height: 16px; }.topbar { min-height: 50px; padding-inline: 20px; }.breadcrumb { font-size: 10px; gap: 9px; }.source-status { font-size: 8px; padding: 6px 8px; }.shell { padding: 29px 18px 0; }.hero { margin-bottom: 25px; }.eyebrow { font-size: 8px; letter-spacing: 1.3px; }h1 { font-size: 43px; letter-spacing: -2.3px; margin-block: 17px 15px; }.hero p { font-size: 12px; line-height: 1.85; max-width: 390px; }.overview { grid-template-columns: 1fr 1fr; padding: 22px 0 0; gap: 19px 0; margin-bottom: 23px; }.overview-stat { padding-inline: 18px; }.overview-stat:nth-child(2) { border: 0; }.overview-stat:last-child { grid-column: 1 / -1; border-top: 1px solid var(--line); padding-block: 15px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 7px; }.overview-stat:last-child > small { width: 100%; }.overview-stat > strong.date-stat { margin: 0; font-size: 17px; }.overview-stat > strong span { display: inline; width: auto; margin-left: 4px; }.stat-label { font-size: 10px; }.overview-stat > strong { font-size: 27px; }.overview-stat > small { font-size: 9px; }.rankings-heading { padding: 22px 18px; align-items: flex-start; }.rankings-heading h2 { font-size: 23px; }.rankings-heading .section-description { font-size: 10px; max-width: 195px; }.rankings-heading > .secondary { font-size: 0; min-height: 34px; width: 34px; padding: 0; gap: 0; }.rankings-heading > .secondary svg { width: 15px; }.filters { padding: 17px 18px; }.filter-top { gap: 10px; }.filter-submit { min-height: 35px; }.filter-bottom { margin-top: -35px; padding-right: 125px; min-height: 70px; }.price-chips { gap: 5px; }.price-chip { min-height: 27px; padding-inline: 10px; }.price-range summary { font-size: 9px; }.range-inputs { right: auto; left: 0; }.results-caption { padding-inline: 18px; gap: 8px; }.results-caption > span { font-size: 9px; gap: 5px; flex-wrap: wrap; }.results-caption .text-button { font-size: 9px; white-space: nowrap; }.table-footer { padding: 15px 18px; align-items: flex-start; }.table-footer p { font-size: 9px; padding-top: 8px; }.pagination { gap: 7px; }.small-button { padding-inline: 8px; font-size: 9px; }.data-note { margin-bottom: 24px; }.bottom-grid { gap: 20px; }.question-panel, .method { padding: 23px 20px; }.question-panel h2, .method h2 { font-size: 25px; }.section-description { font-size: 11px; }.details-panel { padding: 22px 18px; scroll-margin-top: 120px; }.details-heading { gap: 12px; }.details-heading h2 { font-size: 25px; }.detail-actions { gap: 6px; }.detail-actions .secondary { font-size: 0; width: 34px; padding: 0; gap: 0; min-height: 34px; }.detail-stats { padding-block: 20px; }.detail-stats > div { padding-inline: 12px; }.detail-stats strong { font-size: 22px; }.detail-stats small { font-size: 9px; }.detail-stats span { font-size: 8px; }.model-notes dl { grid-template-columns: 1fr; }.change-strip { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; }.change-strip > span { grid-column: 1/-1; }.source-dates { gap: 9px; flex-direction: column; }footer { align-items: flex-start; gap: 13px; }footer p { font-size: 8px; max-width: 220px; line-height: 1.7; } }
    @media (max-width: 380px) { h1 { font-size: 38px; }.nav-link { font-size: 9px; gap: 5px; } }
    @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; }*, *::before, *::after { animation-duration: .01ms !important; transition-duration: .01ms !important; } }
    """}
        </style>;
}
