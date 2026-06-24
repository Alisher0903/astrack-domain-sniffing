#!/bin/bash

DIFF_FILE="reports/diff.json"
RISK_FILE="reports/risk.json"
OUTPUT="reports/report.html"

cat > "$OUTPUT" << EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ASTrack Report</title>

<style>

body{
    background:#0f172a;
    color:white;
    font-family:Arial, sans-serif;
    padding:40px;
}

.card{
    background:#1e293b;
    padding:20px;
    margin-bottom:20px;
    border-radius:10px;
}

.high{
    color:#ef4444;
}

.medium{
    color:#f59e0b;
}

.low{
    color:#22c55e;
}

h1{
    color:#38bdf8;
}

pre{
    white-space:pre-wrap;
    word-wrap:break-word;
}

</style>

</head>
<body>

<h1>Attack Surface Risk Tracker</h1>

<div class="card">
<h2>Risk Findings</h2>
<pre>
$(jq . "$RISK_FILE")
</pre>
</div>

<div class="card">
<h2>Diff Analysis</h2>
<pre>
$(jq . "$DIFF_FILE")
</pre>
</div>

</body>
</html>
EOF

echo "[OK] HTML report created: $OUTPUT"
