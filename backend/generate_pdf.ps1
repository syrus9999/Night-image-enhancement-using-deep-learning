# Generate PDF Report for MIRNet Low-Light Enhancement Project
# This script creates a self-contained HTML file with embedded images
# and converts it to PDF using Microsoft Edge headless mode.

$ErrorActionPreference = "Stop"

# --- Load base64 images ---
Write-Host "Loading base64-encoded images..."
$tc = Get-Content "$PSScriptRoot\training_curves_b64.txt" -Raw
$ds = Get-Content "$PSScriptRoot\dataset_samples_b64.txt" -Raw
$dc = Get-Content "$PSScriptRoot\detail_comparison_b64.txt" -Raw
$md = Get-Content "$PSScriptRoot\metric_distributions_b64.txt" -Raw
Write-Host "  Images loaded."

# --- Build HTML ---
Write-Host "Building HTML report..."

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>MIRNet Low-Light Image Enhancement — Project Report</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500&display=swap');

  :root {
    --primary: #4338ca;
    --primary-light: #6366f1;
    --primary-bg: #eef2ff;
    --accent: #0891b2;
    --success: #059669;
    --warning: #d97706;
    --danger: #dc2626;
    --text: #1e1b4b;
    --text-secondary: #4b5563;
    --text-muted: #9ca3af;
    --border: #e5e7eb;
    --bg: #ffffff;
    --bg-subtle: #f9fafb;
    --code-bg: #f3f4f6;
  }

  @page {
    size: A4;
    margin: 20mm 18mm 20mm 18mm;
  }

  * { margin: 0; padding: 0; box-sizing: border-box; }

  body {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    font-size: 10.5pt;
    line-height: 1.7;
    color: var(--text);
    background: var(--bg);
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }

  /* ── Cover Page ── */
  .cover-page {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    text-align: center;
    page-break-after: always;
    background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 30%, #c7d2fe 60%, #ddd6fe 100%);
    padding: 60px 40px;
    position: relative;
    overflow: hidden;
  }

  .cover-page::before {
    content: '';
    position: absolute;
    top: -100px;
    right: -100px;
    width: 400px;
    height: 400px;
    border-radius: 50%;
    background: rgba(99, 102, 241, 0.08);
  }

  .cover-page::after {
    content: '';
    position: absolute;
    bottom: -80px;
    left: -80px;
    width: 300px;
    height: 300px;
    border-radius: 50%;
    background: rgba(6, 182, 212, 0.06);
  }

  .cover-logo {
    width: 80px;
    height: 80px;
    background: linear-gradient(135deg, #4338ca, #7c3aed);
    border-radius: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 36px;
    color: white;
    margin-bottom: 40px;
    box-shadow: 0 8px 32px rgba(67, 56, 202, 0.3);
  }

  .cover-badge {
    display: inline-block;
    padding: 6px 20px;
    border-radius: 100px;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 2px;
    background: rgba(67, 56, 202, 0.1);
    color: var(--primary);
    border: 1px solid rgba(67, 56, 202, 0.2);
    margin-bottom: 30px;
  }

  .cover-title {
    font-size: 32pt;
    font-weight: 900;
    line-height: 1.15;
    letter-spacing: -1.5px;
    margin-bottom: 16px;
    color: var(--text);
  }

  .cover-title .highlight {
    background: linear-gradient(135deg, #4338ca, #7c3aed);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .cover-subtitle {
    font-size: 14pt;
    color: var(--text-secondary);
    max-width: 500px;
    margin: 0 auto 40px;
    font-weight: 400;
  }

  .cover-meta {
    font-size: 10pt;
    color: var(--text-muted);
    margin-top: 30px;
  }

  .cover-meta strong {
    color: var(--text-secondary);
  }

  .cover-pipeline {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-top: 40px;
    padding: 16px 28px;
    background: rgba(255,255,255,0.7);
    border-radius: 16px;
    border: 1px solid rgba(99,102,241,0.15);
    box-shadow: 0 4px 16px rgba(0,0,0,0.04);
  }

  .cover-pipeline .pipe-step {
    padding: 6px 14px;
    border-radius: 8px;
    font-size: 9pt;
    font-weight: 600;
    background: var(--primary-bg);
    color: var(--primary);
    border: 1px solid rgba(67,56,202,0.15);
  }

  .cover-pipeline .pipe-arrow {
    color: var(--text-muted);
    font-size: 14pt;
  }

  /* ── Table of Contents ── */
  .toc-page {
    page-break-after: always;
    padding: 40px 0;
  }

  .toc-title {
    font-size: 20pt;
    font-weight: 800;
    margin-bottom: 30px;
    padding-bottom: 12px;
    border-bottom: 3px solid var(--primary);
    display: inline-block;
  }

  .toc-list {
    list-style: none;
    counter-reset: toc-counter;
  }

  .toc-list li {
    counter-increment: toc-counter;
    padding: 12px 0;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: baseline;
    gap: 12px;
    font-size: 11pt;
  }

  .toc-list li::before {
    content: counter(toc-counter, decimal-leading-zero);
    font-weight: 800;
    color: var(--primary);
    font-size: 12pt;
    min-width: 30px;
  }

  .toc-list li span {
    font-weight: 500;
  }

  /* ── Section Headers ── */
  .section {
    page-break-inside: avoid;
    margin-bottom: 28px;
  }

  h1.section-title {
    font-size: 20pt;
    font-weight: 800;
    color: var(--text);
    margin-bottom: 6px;
    padding-bottom: 10px;
    border-bottom: 3px solid var(--primary);
    page-break-after: avoid;
    letter-spacing: -0.5px;
  }

  h1.section-title .number {
    color: var(--primary);
    margin-right: 8px;
  }

  h2 {
    font-size: 13pt;
    font-weight: 700;
    color: var(--text);
    margin: 22px 0 10px;
    padding-bottom: 6px;
    border-bottom: 1.5px solid var(--border);
    page-break-after: avoid;
  }

  h3 {
    font-size: 11pt;
    font-weight: 700;
    color: var(--primary);
    margin: 16px 0 8px;
    page-break-after: avoid;
  }

  p {
    margin-bottom: 10px;
    text-align: justify;
  }

  /* ── Callout Boxes ── */
  .callout {
    padding: 14px 18px;
    border-radius: 10px;
    margin: 16px 0;
    font-size: 10pt;
    page-break-inside: avoid;
  }

  .callout-info {
    background: #eff6ff;
    border-left: 4px solid #3b82f6;
    color: #1e40af;
  }

  .callout-success {
    background: #ecfdf5;
    border-left: 4px solid #10b981;
    color: #065f46;
  }

  .callout-warning {
    background: #fffbeb;
    border-left: 4px solid #f59e0b;
    color: #92400e;
  }

  .callout-important {
    background: #fef2f2;
    border-left: 4px solid #ef4444;
    color: #991b1b;
  }

  .callout-title {
    font-weight: 700;
    margin-bottom: 4px;
    font-size: 9.5pt;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  /* ── Tables ── */
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 14px 0;
    font-size: 9.5pt;
    page-break-inside: avoid;
  }

  th {
    background: var(--primary);
    color: white;
    font-weight: 600;
    padding: 10px 14px;
    text-align: left;
    font-size: 9pt;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  th:first-child { border-radius: 8px 0 0 0; }
  th:last-child { border-radius: 0 8px 0 0; }

  td {
    padding: 9px 14px;
    border-bottom: 1px solid var(--border);
    vertical-align: top;
  }

  tr:nth-child(even) td {
    background: var(--bg-subtle);
  }

  tr:last-child td:first-child { border-radius: 0 0 0 8px; }
  tr:last-child td:last-child { border-radius: 0 0 8px 0; }

  /* ── Code Blocks ── */
  code {
    font-family: 'JetBrains Mono', 'Consolas', monospace;
    font-size: 9pt;
    background: var(--code-bg);
    padding: 2px 6px;
    border-radius: 4px;
    color: #7c3aed;
  }

  pre {
    background: #1e1b4b;
    color: #e0e7ff;
    padding: 18px 22px;
    border-radius: 12px;
    font-family: 'JetBrains Mono', 'Consolas', monospace;
    font-size: 8.5pt;
    line-height: 1.6;
    overflow-x: auto;
    margin: 14px 0;
    page-break-inside: avoid;
    white-space: pre-wrap;
    word-wrap: break-word;
  }

  pre code {
    background: none;
    padding: 0;
    color: inherit;
    font-size: inherit;
  }

  .code-comment { color: #a5b4fc; font-style: italic; }
  .code-keyword { color: #c084fc; }
  .code-string { color: #86efac; }
  .code-symbol { color: #fbbf24; }

  /* ── Images ── */
  .figure {
    margin: 20px 0;
    text-align: center;
    page-break-inside: avoid;
  }

  .figure img {
    max-width: 100%;
    border-radius: 10px;
    border: 1px solid var(--border);
    box-shadow: 0 4px 16px rgba(0,0,0,0.06);
  }

  .figure-caption {
    font-size: 9pt;
    color: var(--text-muted);
    margin-top: 8px;
    font-style: italic;
  }

  /* ── Diagram Boxes ── */
  .diagram {
    background: var(--bg-subtle);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 20px;
    margin: 16px 0;
    page-break-inside: avoid;
  }

  .diagram pre {
    background: transparent;
    color: var(--text);
    padding: 0;
    margin: 0;
    border-radius: 0;
    font-size: 8.5pt;
    line-height: 1.5;
  }

  .diagram-title {
    font-size: 9pt;
    font-weight: 700;
    color: var(--primary);
    margin-bottom: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  /* ── Lists ── */
  ul, ol {
    margin: 8px 0 12px 22px;
  }

  li {
    margin-bottom: 5px;
  }

  /* ── File Tree ── */
  .file-tree {
    background: #1e1b4b;
    color: #e0e7ff;
    padding: 20px 24px;
    border-radius: 12px;
    font-family: 'JetBrains Mono', 'Consolas', monospace;
    font-size: 8pt;
    line-height: 1.7;
    margin: 14px 0;
    page-break-inside: avoid;
  }

  .file-tree .folder { color: #fbbf24; }
  .file-tree .file { color: #86efac; }
  .file-tree .comment { color: #a5b4fc; }

  /* ── Page Breaks ── */
  .page-break {
    page-break-before: always;
  }

  /* ── Highlight Box ── */
  .highlight-box {
    background: linear-gradient(135deg, #eef2ff, #e0e7ff);
    border: 1px solid rgba(99,102,241,0.2);
    border-radius: 12px;
    padding: 18px 22px;
    margin: 16px 0;
    page-break-inside: avoid;
  }

  .highlight-box .hb-title {
    font-weight: 700;
    font-size: 10pt;
    color: var(--primary);
    margin-bottom: 8px;
  }

  /* ── Summary Flow ── */
  .flow-box {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    flex-wrap: wrap;
    padding: 18px;
    background: linear-gradient(135deg, #ecfdf5, #d1fae5);
    border-radius: 12px;
    border: 1px solid rgba(5,150,105,0.2);
    margin: 16px 0;
    page-break-inside: avoid;
  }

  .flow-step {
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 9pt;
    font-weight: 600;
    background: white;
    border: 1px solid rgba(5,150,105,0.2);
    color: #065f46;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  }

  .flow-arrow {
    font-size: 16pt;
    color: #059669;
  }

  /* ── Metric Cards ── */
  .metric-row {
    display: flex;
    gap: 16px;
    margin: 16px 0;
    page-break-inside: avoid;
  }

  .metric-card {
    flex: 1;
    text-align: center;
    padding: 18px;
    border-radius: 12px;
    border: 1px solid var(--border);
    background: var(--bg-subtle);
  }

  .metric-card .metric-value {
    font-size: 24pt;
    font-weight: 800;
    background: linear-gradient(135deg, #4338ca, #7c3aed);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .metric-card .metric-label {
    font-size: 8pt;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: var(--text-muted);
    margin-top: 4px;
  }

  .metric-card .metric-desc {
    font-size: 8pt;
    color: var(--text-secondary);
    margin-top: 6px;
  }

  /* ── Footer ── */
  .page-footer {
    margin-top: 60px;
    padding-top: 16px;
    border-top: 2px solid var(--primary);
    text-align: center;
    font-size: 9pt;
    color: var(--text-muted);
    page-break-inside: avoid;
  }

  strong { font-weight: 600; }

  @media print {
    body { font-size: 10pt; }
    .cover-page { min-height: 100vh; }
  }
</style>
</head>
<body>

<!-- ═══════════════════════════════════════════════════════════════════
     COVER PAGE
═══════════════════════════════════════════════════════════════════ -->
<div class="cover-page">
  <div class="cover-logo">🔆</div>
  <div class="cover-badge">Final Year Project Report</div>
  <div class="cover-title">
    Low-Light Image<br>
    <span class="highlight">Enhancement</span><br>
    Using MIRNet
  </div>
  <div class="cover-subtitle">
    A deep learning approach combining Multi-Scale Residual Networks with OpenCV denoising for automated low-light image restoration
  </div>
  <div class="cover-pipeline">
    <span class="pipe-step">🌑 Dark Image</span>
    <span class="pipe-arrow">→</span>
    <span class="pipe-step">🧠 MIRNet</span>
    <span class="pipe-arrow">→</span>
    <span class="pipe-step">🔧 Denoise</span>
    <span class="pipe-arrow">→</span>
    <span class="pipe-step">☀️ Enhanced</span>
  </div>
  <div class="cover-meta">
    <strong>Technologies:</strong> PyTorch · OpenCV · Flask · LOL-v2 Dataset<br>
    <strong>Best PSNR:</strong> 21.68 dB &nbsp;|&nbsp; <strong>Best SSIM:</strong> 0.8726
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     TABLE OF CONTENTS
═══════════════════════════════════════════════════════════════════ -->
<div class="toc-page">
  <div class="toc-title">Table of Contents</div>
  <ol class="toc-list">
    <li><span>Project Overview — What this project does</span></li>
    <li><span>Problem Statement — Why low-light enhancement matters</span></li>
    <li><span>What is Low-Light Image Enhancement?</span></li>
    <li><span>MIRNet Architecture — The deep learning model explained</span></li>
    <li><span>Dataset — LOL-v2 training data</span></li>
    <li><span>Training Process — How the model was trained</span></li>
    <li><span>Two-Stage Enhancement Pipeline</span></li>
    <li><span>System Architecture & Web Application</span></li>
    <li><span>Results & Performance Metrics</span></li>
    <li><span>Project File Structure</span></li>
    <li><span>How to Run the Project</span></li>
    <li><span>Technologies Used & Key Takeaways</span></li>
  </ol>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 1: PROJECT OVERVIEW
═══════════════════════════════════════════════════════════════════ -->
<div class="section">
  <h1 class="section-title"><span class="number">01</span> Project Overview</h1>
  <p>This project builds a <strong>complete end-to-end system</strong> for enhancing images captured in low-light conditions. It combines three core technologies:</p>

  <ul>
    <li><strong>MIRNet (Multi-Scale Residual Network)</strong> — A deep learning model specifically designed for low-light image enhancement</li>
    <li><strong>OpenCV Denoising</strong> — A classical computer vision technique (<code>fastNlMeansDenoisingColored</code>) to clean up residual noise after enhancement</li>
    <li><strong>Flask Web Application</strong> — A user-friendly web interface where anyone can upload a dark image and receive an enhanced result</li>
  </ul>

  <div class="callout callout-important">
    <div class="callout-title">💡 Key Innovation</div>
    The <strong>two-stage pipeline</strong> is the key innovation: first, MIRNet brightens the dark image using deep learning, then OpenCV removes noise artifacts that may appear after enhancement. This combination produces cleaner results than either technique alone.
  </div>

  <div class="flow-box">
    <span class="flow-step">🌑 Dark Image</span>
    <span class="flow-arrow">→</span>
    <span class="flow-step">🧠 MIRNet Enhancement</span>
    <span class="flow-arrow">→</span>
    <span class="flow-step">🔧 OpenCV Denoise</span>
    <span class="flow-arrow">→</span>
    <span class="flow-step">☀️ Clean Enhanced Image</span>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 2: PROBLEM STATEMENT
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">02</span> Problem Statement</h1>
  <p>Images captured in low-light environments (nighttime, dimly lit rooms, shadows) suffer from several quality issues:</p>

  <table>
    <tr><th>Problem</th><th>Description</th></tr>
    <tr><td><strong>Low visibility</strong></td><td>Objects and details are hidden in darkness, making the image unusable</td></tr>
    <tr><td><strong>High noise</strong></td><td>Camera sensors produce random color/brightness variations (grain) in dark conditions</td></tr>
    <tr><td><strong>Poor contrast</strong></td><td>Everything appears flat and washed out — no clear distinction between objects</td></tr>
    <tr><td><strong>Color distortion</strong></td><td>Colors shift and become inaccurate due to insufficient light reaching the sensor</td></tr>
  </table>

  <p><strong>Goal:</strong> Build an automated system that takes a dark, noisy image as input and produces a bright, clean, well-lit image as output — while preserving natural colors and fine details.</p>

  <h2>Real-World Applications</h2>
  <table>
    <tr><th>Domain</th><th>Application</th></tr>
    <tr><td>🔒 Surveillance & Security</td><td>Enhance CCTV footage captured at night for forensic analysis</td></tr>
    <tr><td>🚗 Autonomous Driving</td><td>Improve visibility for self-driving car cameras in poor lighting conditions</td></tr>
    <tr><td>📷 Photography</td><td>Rescue underexposed photos without manual editing in Photoshop</td></tr>
    <tr><td>🏥 Medical Imaging</td><td>Enhance poorly lit endoscopy or microscopy images</td></tr>
    <tr><td>🛰️ Satellite Imagery</td><td>Improve low-light satellite and aerial photographs</td></tr>
  </table>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 3: WHAT IS LOW-LIGHT ENHANCEMENT
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">03</span> What is Low-Light Image Enhancement?</h1>
  <p>Low-Light Image Enhancement (LLIE) is the task of <strong>recovering a well-lit image from a degraded low-light input</strong>. Think of it as "digitally adding light" to a dark photograph while preserving natural appearance.</p>

  <h2>Traditional Approaches vs Deep Learning</h2>
  <table>
    <tr><th>Approach</th><th>Method</th><th>Limitation</th></tr>
    <tr><td>Histogram Equalization</td><td>Stretches pixel intensity distribution to use the full range</td><td>Over-enhances bright areas, loses detail in highlights</td></tr>
    <tr><td>Retinex Theory</td><td>Decomposes image into illumination & reflectance components</td><td>Amplifies existing noise significantly</td></tr>
    <tr><td>Gamma Correction</td><td>Applies power-law transform to brighten all pixels</td><td>No noise handling, applies uniform adjustment everywhere</td></tr>
    <tr><td><strong>Deep Learning (MIRNet) ✅</strong></td><td>Learns optimal enhancement from thousands of paired examples</td><td>Requires training data & GPU (but produces best results)</td></tr>
  </table>

  <div class="callout callout-success">
    <div class="callout-title">✅ Why Deep Learning Wins</div>
    Deep learning approaches like MIRNet <strong>learn</strong> what a well-lit version of a dark image should look like by training on thousands of paired examples (dark image → well-lit image). This produces far more natural, artifact-free results than rule-based methods because the model learns complex relationships between lighting, color, texture, and noise.
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 4: MIRNET ARCHITECTURE
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">04</span> MIRNet Architecture</h1>
  <p><strong>MIRNet</strong> stands for <strong>Multi-Scale Residual Network</strong> for Image Restoration. It was proposed in the paper <em>"Learning Enriched Features for Real Image Restoration and Enhancement"</em> by Zamir et al. at ECCV 2020.</p>

  <h2>Why MIRNet Was Chosen</h2>
  <ol>
    <li><strong>Multi-scale processing</strong> — Processes the image at multiple resolutions simultaneously, capturing both fine details (textures, edges) and global context (overall lighting)</li>
    <li><strong>Dual attention mechanism</strong> — Uses both channel attention (<em>what</em> features to focus on) and spatial attention (<em>where</em> in the image to focus) for precise, context-aware enhancement</li>
    <li><strong>Residual learning</strong> — Learns the <em>difference</em> between dark and light images rather than generating from scratch, making training more stable and efficient</li>
  </ol>

  <h2>High-Level Architecture</h2>
  <div class="diagram">
    <div class="diagram-title">MIRNet — End-to-End Flow</div>
<pre>
Input Image (3 channels: RGB)
      │
      ▼
┌────────────────────────────────┐
│  Shallow Feature Extraction    │  Conv2d(3 → 64 features)
│  (Single 3×3 convolution)      │
└────────────┬───────────────────┘
             │
             ▼
┌────────────────────────────────┐
│  RRG × 3 (Recursive Residual  │  ← Main processing stages
│  Groups), each containing      │
│  MRB × 2 (Multi-scale         │  ← Core processing blocks
│  Residual Blocks)              │
└────────────┬───────────────────┘
             │
             ▼
┌────────────────────────────────┐
│  Reconstruction Layer          │  Conv2d(64 → 3 channels)
│  + Global Skip Connection      │  Output = Reconstruction + Input
└────────────┬───────────────────┘
             │
             ▼
  Enhanced Image (RGB, clamped to [0,1])
</pre>
  </div>

  <h2>Building Blocks Explained</h2>

  <h3>🔷 RRG — Recursive Residual Group</h3>
  <p>Think of each RRG as a <strong>processing stage</strong>. The model has <strong>3 RRGs</strong> stacked sequentially. Each RRG contains <strong>2 MRBs</strong> for heavy processing and has a <strong>skip connection</strong> — it adds its input back to its output, so the model only needs to learn the "correction" rather than the entire output. This makes training much easier.</p>

  <h3>🔷 MRB — Multi-scale Residual Block</h3>
  <p>This is the <strong>heart of MIRNet</strong>. Each MRB processes the image at <strong>two different scales</strong> simultaneously:</p>

  <div class="diagram">
    <div class="diagram-title">Multi-scale Residual Block (MRB)</div>
<pre>
Input Feature Map
      │
      ├─────────────────────┐
      │                     │
      ▼                     ▼
┌──────────┐          ┌──────────┐
│ Scale 1  │          │ Scale 2  │  ← Downsampled to half resolution
│   DAU    │          │   DAU    │  (Captures broader context)
└────┬─────┘          └────┬─────┘
     │                     │
     │    Cross-scale      │
     │◄── information  ──► │    (Features exchange between scales)
     │    exchange         │
     │                     │
     ▼                     ▼
┌──────────────────────────────┐
│  SKFF (Selective Fusion)     │  ← Merges both scales intelligently
└──────────┬───────────────────┘
           │
           ▼
    Output (+ Skip from Input)
</pre>
  </div>

  <p><strong>Why two scales?</strong></p>
  <ul>
    <li><strong>Scale 1</strong> (original resolution) — Captures fine details like textures, edges, and small features</li>
    <li><strong>Scale 2</strong> (half resolution) — Captures broader patterns like overall lighting distribution and large structures</li>
  </ul>

  <h3>🔷 DAU — Dual Attention Unit</h3>
  <p>Each DAU applies <strong>two types of attention in parallel</strong>, then combines them:</p>

  <table>
    <tr><th>Attention Type</th><th>What It Does</th><th>Simple Analogy</th></tr>
    <tr><td><strong>Channel Attention</strong></td><td>Decides <em>which features</em> (brightness, edges, colors) are most important for this region</td><td>"Focus on the brightness channel more than color here"</td></tr>
    <tr><td><strong>Spatial Attention</strong></td><td>Decides <em>where in the image</em> to focus enhancement effort</td><td>"Enhance this dark shadow region more than the bright sky"</td></tr>
  </table>

  <p>Channel Attention uses a squeeze-and-excitation mechanism: Global Average Pooling → Linear → ReLU → Linear → Sigmoid. This produces per-channel importance weights.</p>
  <p>Spatial Attention uses 1×1 convolutions to produce a per-pixel importance map, highlighting which spatial locations need more enhancement.</p>

  <h3>🔷 SKFF — Selective Kernel Feature Fusion</h3>
  <p>SKFF decides <strong>how much weight to give</strong> features from each scale when merging. It uses a softmax-based attention:</p>
  <ol>
    <li>Sum features from both scales</li>
    <li>Global Average Pooling → FC layer → produces compact descriptor</li>
    <li>Separate FC layers + Softmax produce weights (e.g., 0.6 for Scale 1, 0.4 for Scale 2)</li>
    <li>Weighted combination of both scale features produces the fused output</li>
  </ol>

  <h2>Model Configuration</h2>
  <table>
    <tr><th>Parameter</th><th>Value</th><th>Description</th></tr>
    <tr><td><code>in_channels</code></td><td>3</td><td>RGB input</td></tr>
    <tr><td><code>out_channels</code></td><td>3</td><td>RGB output</td></tr>
    <tr><td><code>n_features</code></td><td>64</td><td>Number of feature maps per layer</td></tr>
    <tr><td><code>n_rrg</code></td><td>3</td><td>Number of Recursive Residual Groups</td></tr>
    <tr><td><code>n_mrb</code></td><td>2</td><td>Number of Multi-scale Residual Blocks per RRG</td></tr>
    <tr><td><code>reduction</code></td><td>4</td><td>Channel reduction ratio for attention modules</td></tr>
    <tr><td><strong>Total Parameters</strong></td><td><strong>~4.7 million</strong></td><td>Moderately sized — fast enough for real-time use</td></tr>
  </table>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 5: DATASET
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">05</span> Dataset — LOL-v2</h1>
  <p>The model is trained on the <strong>LOL-v2 (Low-Light) dataset</strong>, a benchmark dataset specifically created for low-light image enhancement research.</p>

  <h2>Dataset Structure</h2>
  <div class="file-tree">
    <span class="folder">LOL-v2/</span><br>
    ├── <span class="folder">Real_captured/</span> <span class="comment">← Real photographs taken in dark conditions</span><br>
    │   ├── <span class="folder">Train/</span><br>
    │   │   ├── <span class="folder">Low/</span> <span class="comment">← Low-light input images (what the model sees)</span><br>
    │   │   └── <span class="folder">Normal/</span> <span class="comment">← Well-lit ground truth images (what the model should produce)</span><br>
    │   └── <span class="folder">Test/</span><br>
    │       ├── <span class="folder">Low/</span> <span class="comment">← Low-light test images</span><br>
    │       └── <span class="folder">Normal/</span> <span class="comment">← Ground truth for evaluation</span><br>
    └── <span class="folder">Synthetic/</span> <span class="comment">← Synthetically darkened images (additional training data)</span><br>
    &nbsp;&nbsp;&nbsp;&nbsp;├── <span class="folder">Train/</span><br>
    &nbsp;&nbsp;&nbsp;&nbsp;└── <span class="folder">Test/</span>
  </div>

  <h2>How the Dataset Works</h2>
  <p>Each training example is a <strong>paired set</strong>: a low-light image (the input) and a corresponding normal-light image (the target). The model learns to transform the "Low" image into the "Normal" image by minimizing the difference between its prediction and the ground truth.</p>

  <h2>Dataset Samples</h2>
  <div class="figure">
    <img src="data:image/png;base64,${ds}" alt="LOL-v2 Training Pairs">
    <div class="figure-caption">Figure 1: LOL-v2 Training Pairs — Top row: low-light inputs showing dark, underexposed images. Bottom row: corresponding normal-light ground truth images showing what the model should learn to produce.</div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 6: TRAINING PROCESS
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">06</span> Training Process</h1>

  <h2>Loss Functions</h2>
  <p>The model was trained with a <strong>composite loss function</strong> combining three objectives, each serving a different purpose:</p>

  <table>
    <tr><th>Loss Component</th><th>Purpose</th><th>Why It's Needed</th></tr>
    <tr><td><strong>Charbonnier Loss</strong></td><td>Pixel-level accuracy</td><td>Robust alternative to MSE — less sensitive to outliers, preserves sharpness instead of producing blurry "average" outputs</td></tr>
    <tr><td><strong>Edge Loss</strong></td><td>Structural detail preservation</td><td>Ensures sharp edges, boundaries, and textures are maintained in the enhanced image</td></tr>
    <tr><td><strong>SSIM Loss</strong></td><td>Perceptual quality</td><td>Ensures the overall structure, luminance, and contrast match the ground truth as perceived by human vision</td></tr>
  </table>

  <div class="callout callout-info">
    <div class="callout-title">ℹ️ Why Charbonnier Instead of MSE?</div>
    MSE (Mean Squared Error) penalizes large errors quadratically, which causes the model to produce blurry "average" outputs — it plays it safe. Charbonnier loss (L1-like but differentiable at zero) is more robust and better preserves sharp details.
  </div>

  <h2>Training Configuration</h2>
  <table>
    <tr><th>Setting</th><th>Value</th></tr>
    <tr><td>Optimizer</td><td>Adam (adaptive learning rate optimizer)</td></tr>
    <tr><td>Initial Learning Rate</td><td>~1×10⁻⁴</td></tr>
    <tr><td>LR Schedule</td><td>Cosine Annealing (gradually decreases LR for fine-tuning)</td></tr>
    <tr><td>Total Epochs</td><td>150</td></tr>
    <tr><td>Training Data</td><td>Random crops from LOL-v2 training images</td></tr>
    <tr><td>Device</td><td>GPU (CUDA) when available, CPU fallback</td></tr>
    <tr><td>Checkpoints Saved</td><td>Every 25 epochs + best model (highest val PSNR)</td></tr>
  </table>

  <h2>Training Curves</h2>
  <div class="figure">
    <img src="data:image/png;base64,${tc}" alt="MIRNet Training Curves">
    <div class="figure-caption">Figure 2: MIRNet Training Curves over 150 epochs — showing loss convergence (top row), validation PSNR & SSIM improvement (bottom-left & center), and cosine annealing learning rate schedule (bottom-right).</div>
  </div>

  <h2>Reading the Training Curves</h2>
  <table>
    <tr><th>Plot</th><th>What It Shows</th><th>Key Observation</th></tr>
    <tr><td><strong>Total Loss</strong> (top-left)</td><td>Overall training loss per epoch</td><td>Rapid drop in first 20 epochs → gradual refinement. Classic healthy convergence.</td></tr>
    <tr><td><strong>Component Losses</strong> (top-center)</td><td>Charbonnier & Edge loss separately</td><td>Both decrease smoothly — model learns pixel accuracy AND edge preservation simultaneously.</td></tr>
    <tr><td><strong>SSIM Loss</strong> (top-right)</td><td>Structural similarity loss</td><td>Sharp initial improvement — model quickly learns structural patterns in lighting.</td></tr>
    <tr><td><strong>Validation PSNR</strong> (bottom-left)</td><td>Image quality on test data (higher = better)</td><td>Reaches <strong>best of 21.68 dB</strong>. Some oscillation is normal — the best checkpoint is saved.</td></tr>
    <tr><td><strong>Validation SSIM</strong> (bottom-center)</td><td>Structural similarity on test data</td><td>Steadily increases from ~0.67 to <strong>~0.87</strong> — strong structural preservation.</td></tr>
    <tr><td><strong>Learning Rate</strong> (bottom-right)</td><td>Cosine annealing LR schedule</td><td>Starts high (1e-4) for broad exploration, gradually decreases for precise fine-tuning.</td></tr>
  </table>

  <h2>Saved Checkpoints</h2>
  <table>
    <tr><th>Checkpoint File</th><th>Epoch</th><th>Purpose</th></tr>
    <tr><td><code>mirnet_epoch25.pth</code> through <code>mirnet_epoch150.pth</code></td><td>25, 50, 75, 100, 125, 150</td><td>Periodic snapshots every 25 epochs</td></tr>
    <tr><td><strong><code>mirnet_best.pth</code> ✅</strong></td><td>Best PSNR</td><td><strong>Used in deployment</strong> — highest validation PSNR achieved</td></tr>
    <tr><td><code>mirnet_final.pth</code></td><td>150</td><td>Final epoch weights (may differ from best)</td></tr>
  </table>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 7: TWO-STAGE PIPELINE
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">07</span> Two-Stage Enhancement Pipeline</h1>

  <div class="diagram">
    <div class="diagram-title">Complete Enhancement Pipeline</div>
<pre>
┌──────────────────────────────────────────────────────────────────────┐
│                     ENHANCEMENT PIPELINE                            │
│                                                                      │
│  ┌──────────┐     ┌─────────────────┐     ┌──────────────────────┐  │
│  │  Upload  │────►│  Stage 1:       │────►│  Stage 2:            │  │
│  │  Dark    │     │  MIRNet         │     │  OpenCV Denoise      │  │
│  │  Image   │     │  Enhancement    │     │  (FastNlMeans)       │  │
│  └──────────┘     └─────────────────┘     └──────────┬───────────┘  │
│                                                      │              │
│                                          ┌───────────▼───────────┐  │
│                                          │  Final Enhanced Image │  │
│                                          └───────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
</pre>
  </div>

  <h2>Stage 1: MIRNet Enhancement</h2>
  <p><strong>What it does:</strong> Takes the dark input image and produces a brightened version using the trained neural network.</p>
  <p><strong>Technical steps:</strong></p>
  <ol>
    <li>Load image and convert to tensor (float values in range [0, 1])</li>
    <li>Pad image dimensions to multiples of 8 (required by the network's downsampling layers)</li>
    <li>Run through MIRNet in inference mode (no gradient computation — <code>torch.no_grad()</code>)</li>
    <li>Remove padding and clamp output values to [0, 1]</li>
  </ol>
  <p><strong>Result:</strong> A significantly brighter image, but may contain some noise artifacts introduced during the enhancement process.</p>

  <h2>Stage 2: OpenCV Denoising</h2>
  <p><strong>What it does:</strong> Cleans up residual noise from Stage 1 using classical computer vision.</p>
  <p><strong>Method:</strong> <code>cv2.fastNlMeansDenoisingColored()</code> — a non-local means denoising algorithm that:</p>
  <ul>
    <li>Searches for similar patches across the entire image</li>
    <li>Averages similar patches to reduce random noise</li>
    <li>Preserves edges and textures better than simple blurring (Gaussian blur would destroy details)</li>
  </ul>

  <table>
    <tr><th>Parameter</th><th>Value</th><th>Description</th></tr>
    <tr><td><code>h</code></td><td>5</td><td>Filter strength for luminance — moderate to avoid over-smoothing</td></tr>
    <tr><td><code>hColor</code></td><td>5</td><td>Filter strength for color components</td></tr>
    <tr><td><code>templateWindowSize</code></td><td>7</td><td>Size of patch used for comparison (7×7 pixels)</td></tr>
    <tr><td><code>searchWindowSize</code></td><td>21</td><td>Size of area to search for similar patches (21×21 pixels)</td></tr>
  </table>

  <div class="callout callout-warning">
    <div class="callout-title">⚠️ Design Decision</div>
    The denoising parameters are intentionally moderate (<code>h=5</code>). Higher values would remove more noise but also blur fine details. The chosen values strike a balance — enough denoising to clean artifacts without losing the texture details that MIRNet worked hard to recover.
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 8: SYSTEM ARCHITECTURE
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">08</span> System Architecture & Web Application</h1>

  <h2>Overall System Architecture</h2>
  <div class="diagram">
    <div class="diagram-title">System Architecture — Frontend ↔ Backend ↔ Model</div>
<pre>
┌───────────────────────────────────────────┐
│          FRONTEND (Browser)               │
│  ┌──────────────────────────────────────┐ │
│  │  test.html — Web UI                  │ │
│  │  • Drag & drop image upload          │ │
│  │  • Before/after comparison slider    │ │
│  │  • Performance stats display         │ │
│  │  • Health check panel                │ │
│  └──────────────┬───────────────────────┘ │
└─────────────────┼─────────────────────────┘
                  │ HTTP POST /api/enhance
                  ▼
┌───────────────────────────────────────────┐
│          BACKEND (Flask Server)           │
│  ┌──────────────────────────────────────┐ │
│  │  app.py — Routes & Request Handling  │ │
│  │  config.py — Centralized Config      │ │
│  │  utils.py — Model Loading & Helpers  │ │
│  └──────────────┬───────────────────────┘ │
│                 ▼                         │
│  ┌──────────────────────────────────────┐ │
│  │  pipeline.py — Enhancement Pipeline  │ │
│  │  Stage 1: MIRNet → Stage 2: Denoise │ │
│  └──────────────┬───────────────────────┘ │
│                 ▼                         │
│  ┌──────────────────────────────────────┐ │
│  │  models/mirnet.py — Neural Network   │ │
│  │  checkpoints/mirnet_best.pth         │ │
│  └──────────────────────────────────────┘ │
└───────────────────────────────────────────┘
</pre>
  </div>

  <h2>API Endpoints</h2>
  <table>
    <tr><th>Method</th><th>Endpoint</th><th>Description</th></tr>
    <tr><td><code>GET</code></td><td><code>/</code></td><td>Serves the web-based test UI (test.html)</td></tr>
    <tr><td><code>GET</code></td><td><code>/api/health</code></td><td>Health check — returns server status, device info (CPU/GPU), model parameters</td></tr>
    <tr><td><code>POST</code></td><td><code>/api/enhance</code></td><td>Upload image → run full pipeline → return original + enhanced as Base64 JSON</td></tr>
  </table>

  <h2>API Response Format (<code>/api/enhance</code>)</h2>
  <pre><code>{
    "original_image":    "data:image/jpeg;base64,/9j/4AAQ...",
    "enhanced_image":    "data:image/jpeg;base64,/9j/4AAQ...",
    "original_filename": "dark_photo.jpg",
    "input_size":        { "width": 1920, "height": 1080 },
    "output_size":       { "width": 1920, "height": 1080 },
    "mirnet_time_ms":    1250.5,
    "denoise_time_ms":   340.2,
    "total_time_ms":     1590.7
}</code></pre>

  <h2>Web Interface Features</h2>
  <ul>
    <li><strong>Drag & Drop Upload</strong> — Drag images directly onto the page or click to browse</li>
    <li><strong>Supported Formats</strong> — PNG, JPG, JPEG, BMP, TIF, TIFF (max 16 MB file size)</li>
    <li><strong>Interactive Before/After Slider</strong> — Drag a slider to compare original vs enhanced side-by-side</li>
    <li><strong>Performance Statistics</strong> — Shows MIRNet inference time, denoise time, total time, and image dimensions</li>
    <li><strong>Health Check Panel</strong> — Slide-over panel showing server status, GPU info, model parameter count</li>
    <li><strong>Download Enhanced Image</strong> — One-click download of the enhanced result</li>
    <li><strong>Modern Glassmorphism Design</strong> — Professional, responsive UI with animations</li>
    <li><strong>CORS Enabled</strong> — Frontend can run on a different port/domain than the backend</li>
  </ul>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 9: RESULTS
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">09</span> Results & Performance Metrics</h1>

  <h2>Quantitative Metrics</h2>
  <div class="metric-row">
    <div class="metric-card">
      <div class="metric-value">21.68 dB</div>
      <div class="metric-label">Peak Signal-to-Noise Ratio (PSNR)</div>
      <div class="metric-desc">Pixel-level accuracy — higher is better. 20–25 dB is typical for this task.</div>
    </div>
    <div class="metric-card">
      <div class="metric-value">0.8726</div>
      <div class="metric-label">Structural Similarity (SSIM)</div>
      <div class="metric-desc">Perceptual quality — range 0 to 1 (1 = perfect). >0.85 is strong.</div>
    </div>
  </div>

  <h2>Understanding PSNR and SSIM</h2>
  <table>
    <tr><th>Metric</th><th>What It Measures</th><th>How to Interpret</th></tr>
    <tr>
      <td><strong>PSNR</strong></td>
      <td>Pixel-by-pixel accuracy compared to ground truth. Measured in decibels (dB).</td>
      <td>Higher = better. 20 dB = good, 25 dB = very good, 30+ dB = excellent. Our 21.68 dB indicates solid restoration.</td>
    </tr>
    <tr>
      <td><strong>SSIM</strong></td>
      <td>Perceived visual quality — compares luminance, contrast, and structure (closer to how humans judge quality).</td>
      <td>Range 0–1. 0.87 means the enhanced images closely match ground truth structurally, with natural appearance.</td>
    </tr>
  </table>

  <h2>Metric Distributions Across Test Set</h2>
  <div class="figure">
    <img src="data:image/png;base64,${md}" alt="Metric Distributions">
    <div class="figure-caption">Figure 3: PSNR and SSIM distributions across all LOL-v2 test images. Mean PSNR: 21.68 dB, Mean SSIM: 0.8726. The majority of test images achieve >15 dB PSNR and >0.80 SSIM.</div>
  </div>

  <h2>Visual Results — Detail Comparison</h2>
  <div class="figure">
    <img src="data:image/png;base64,${dc}" alt="Detail Comparison">
    <div class="figure-caption">Figure 4: Cropped detail comparison — Top row: low-light input crops. Bottom row: MIRNet enhanced output crops. Notice the recovery of individual stadium seats, foliage details, sculptural features, and architectural ornaments.</div>
  </div>

  <div class="callout callout-success">
    <div class="callout-title">✅ Key Visual Observations</div>
    <ul>
      <li><strong>Stadium seats (left):</strong> Individual seats become visible with accurate blue color recovery</li>
      <li><strong>Foliage (center-left):</strong> Leaves and branches emerge from near-total darkness</li>
      <li><strong>Statue (center-right):</strong> Fine sculptural details preserved with natural contrast</li>
      <li><strong>Ceiling architecture (right):</strong> Ornate details and gold tones recovered faithfully</li>
    </ul>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 10: FILE STRUCTURE
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">10</span> Project File Structure</h1>

  <div class="file-tree">
    <span class="folder">📁 Project Root/</span><br>
    │<br>
    ├── <span class="folder">📁 backend/</span> <span class="comment">← Flask Web Application</span><br>
    │   ├── <span class="file">app.py</span> <span class="comment">← Main Flask server entry point (169 lines)</span><br>
    │   ├── <span class="file">config.py</span> <span class="comment">← Centralized configuration (device, paths, hyperparams)</span><br>
    │   ├── <span class="file">pipeline.py</span> <span class="comment">← Two-stage enhancement pipeline logic</span><br>
    │   ├── <span class="file">utils.py</span> <span class="comment">← Utility functions (model loading, base64 encoding)</span><br>
    │   ├── <span class="file">requirements.txt</span> <span class="comment">← Python package dependencies</span><br>
    │   │<br>
    │   ├── <span class="folder">📁 models/</span><br>
    │   │   └── <span class="file">mirnet.py</span> <span class="comment">← Complete MIRNet architecture in PyTorch (225 lines)</span><br>
    │   │<br>
    │   ├── <span class="folder">📁 checkpoints_mirnet/</span><br>
    │   │   └── <span class="file">mirnet_best.pth</span> <span class="comment">← Best trained model weights (~19 MB)</span><br>
    │   │<br>
    │   ├── <span class="folder">📁 templates/</span><br>
    │   │   └── <span class="file">test.html</span> <span class="comment">← Frontend web interface (1464 lines)</span><br>
    │   │<br>
    │   ├── <span class="folder">📁 uploads/</span> <span class="comment">← Uploaded images (temporary storage)</span><br>
    │   ├── <span class="folder">📁 outputs/</span> <span class="comment">← Enhanced output images</span><br>
    │   └── <span class="folder">📁 venv/</span> <span class="comment">← Python virtual environment</span><br>
    │<br>
    ├── <span class="folder">📁 LOL-v2/</span> <span class="comment">← Training Dataset</span><br>
    │   ├── <span class="folder">📁 Real_captured/</span> (Train/Test with Low/ + Normal/ pairs)<br>
    │   └── <span class="folder">📁 Synthetic/</span> (Train/Test)<br>
    │<br>
    ├── <span class="folder">📁 checkpoints_mirnet/</span> <span class="comment">← All training checkpoints (8 files, ~19 MB each)</span><br>
    ├── <span class="folder">📁 results_mirnet/</span> <span class="comment">← Evaluation results, plots, comparison images</span><br>
    ├── <span class="folder">📁 sharpness_model/</span> <span class="comment">← Super-resolution models (DAT_x2, DAT_x4)</span><br>
    ├── <span class="folder">📁 test/</span> <span class="comment">← Test images (low/ and enhanced/)</span><br>
    │<br>
    ├── <span class="file">MIRNet_LOLv2 Version 2.ipynb</span> <span class="comment">← Main training notebook</span><br>
    ├── <span class="file">MIRNet_Inference.ipynb</span> <span class="comment">← Inference notebook</span><br>
    └── <span class="file">Pipeline_MIRNet_CV.ipynb</span> <span class="comment">← Pipeline development notebook</span>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 11: HOW TO RUN
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">11</span> How to Run the Project</h1>

  <h2>Prerequisites</h2>
  <ul>
    <li>Python 3.8 or higher</li>
    <li>NVIDIA GPU with CUDA support (recommended for fast inference; CPU also works but slower)</li>
    <li>~2 GB disk space for model weights</li>
  </ul>

  <h2>Step-by-Step Setup</h2>

  <h3>Step 1: Create Virtual Environment</h3>
  <pre><code>cd backend
python -m venv venv
venv\Scripts\activate          # Windows
# source venv/bin/activate     # Linux/Mac</code></pre>

  <h3>Step 2: Install Dependencies</h3>
  <pre><code>pip install flask flask-cors torch torchvision opencv-python numpy Pillow</code></pre>

  <div class="callout callout-info">
    <div class="callout-title">ℹ️ GPU Acceleration</div>
    For GPU support (much faster inference), install PyTorch with CUDA instead:<br>
    <code>pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121</code>
  </div>

  <h3>Step 3: Verify Checkpoint</h3>
  <p>Ensure <code>backend/checkpoints_mirnet/mirnet_best.pth</code> exists. This file (~19 MB) contains the trained model weights.</p>

  <h3>Step 4: Start the Server</h3>
  <pre><code>python app.py</code></pre>
  <p>The server starts on <strong>http://localhost:5000</strong>. You will see diagnostic output showing PyTorch version, CUDA availability, and model loading confirmation.</p>

  <h3>Step 5: Use the Application</h3>
  <ol>
    <li>Open <strong>http://localhost:5000</strong> in your web browser</li>
    <li>Drag and drop a dark image onto the upload zone (or click to browse)</li>
    <li>Wait for processing (typically 1–3 seconds on GPU, 5–15 seconds on CPU)</li>
    <li>Use the interactive slider to compare before and after</li>
    <li>Click "Download Enhanced" to save the result</li>
  </ol>
</div>

<!-- ═══════════════════════════════════════════════════════════════════
     SECTION 12: TECHNOLOGIES & TAKEAWAYS
═══════════════════════════════════════════════════════════════════ -->
<div class="section page-break">
  <h1 class="section-title"><span class="number">12</span> Technologies Used & Key Takeaways</h1>

  <h2>Technology Stack</h2>
  <table>
    <tr><th>Category</th><th>Technology</th><th>Purpose</th></tr>
    <tr><td>Deep Learning</td><td>PyTorch</td><td>Model definition, training, and inference</td></tr>
    <tr><td>Computer Vision</td><td>OpenCV (cv2)</td><td>Post-processing denoising (Stage 2)</td></tr>
    <tr><td>Image Processing</td><td>Pillow (PIL)</td><td>Image I/O and format conversion</td></tr>
    <tr><td>Tensor Operations</td><td>NumPy</td><td>Numerical array operations and conversions</td></tr>
    <tr><td>Web Framework</td><td>Flask</td><td>Backend REST API server</td></tr>
    <tr><td>CORS</td><td>Flask-CORS</td><td>Cross-origin request support</td></tr>
    <tr><td>Frontend</td><td>HTML5, CSS3, JS</td><td>Web-based user interface</td></tr>
    <tr><td>Dataset</td><td>LOL-v2</td><td>Paired low-light / normal-light training images</td></tr>
    <tr><td>Development</td><td>Jupyter Notebooks</td><td>Training experimentation & visualization</td></tr>
  </table>

  <h2>Key Takeaways</h2>

  <div class="highlight-box">
    <div class="hb-title">1. Two-Stage Pipeline — Best of Both Worlds</div>
    <p>Combines deep learning (MIRNet for brightness restoration) with classical CV (OpenCV for noise cleanup). The deep learning model handles the complex task of understanding lighting and color, while OpenCV provides efficient, reliable denoising as a post-processing step.</p>
  </div>

  <div class="highlight-box">
    <div class="hb-title">2. Production-Ready Deployment</div>
    <p>This is not just a notebook experiment — it's a fully deployable web application with REST APIs, file upload handling, error handling, base64 image encoding, and a polished, responsive user interface.</p>
  </div>

  <div class="highlight-box">
    <div class="hb-title">3. Comprehensive Training</div>
    <p>Trained for 150 epochs with a sophisticated multi-component loss function (Charbonnier + Edge + SSIM) and cosine annealing learning rate schedule. Multiple checkpoints saved for reproducibility.</p>
  </div>

  <div class="highlight-box">
    <div class="hb-title">4. Strong Quantitative Results</div>
    <p>Achieves <strong>21.68 dB PSNR</strong> and <strong>0.8726 SSIM</strong> on the LOL-v2 benchmark, demonstrating effective low-light enhancement with high structural fidelity.</p>
  </div>

  <div class="highlight-box">
    <div class="hb-title">5. Hardware Flexibility</div>
    <p>Automatically detects and uses GPU (CUDA) for acceleration when available, with seamless CPU fallback. Diagnostic output at startup confirms device and model status.</p>
  </div>

  <h2>One-Sentence Summary</h2>
  <div class="callout callout-important">
    <div class="callout-title">📌 Project Summary</div>
    <p>This project uses a deep neural network called <strong>MIRNet</strong>, trained on thousands of paired dark/light images from the LOL-v2 dataset, to automatically brighten photographs taken in low-light conditions, followed by <strong>OpenCV denoising</strong> to clean up residual noise, all wrapped in a <strong>user-friendly Flask web application</strong> with an interactive before/after comparison interface.</p>
  </div>

  <div class="page-footer">
    <strong>Low-Light Image Enhancement Using MIRNet with OpenCV Denoising</strong><br>
    Final Year Project Report
  </div>
</div>

</body>
</html>
"@

# --- Write HTML ---
$htmlPath = "e:\final year project antigarvity\Project_Report.html"
$html | Out-File -FilePath $htmlPath -Encoding utf8
Write-Host "  HTML saved to: $htmlPath"

# --- Convert to PDF using Edge headless ---
Write-Host "Converting to PDF using Microsoft Edge..."
$pdfPath = "e:\final year project antigarvity\Project_Report.pdf"

# Find Edge executable
$edgePaths = @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)

$edgeExe = $null
foreach ($p in $edgePaths) {
    if (Test-Path $p) {
        $edgeExe = $p
        break
    }
}

if ($edgeExe) {
    $fileUri = "file:///" + ($htmlPath -replace '\\', '/')
    & $edgeExe --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="$pdfPath" $fileUri 2>&1
    Start-Sleep -Seconds 5
    if (Test-Path $pdfPath) {
        $size = (Get-Item $pdfPath).Length / 1KB
        Write-Host "  PDF generated: $pdfPath ($([math]::Round($size, 1)) KB)"
    } else {
        Write-Host "  [!] PDF not found. Trying alternative..."
    }
} else {
    Write-Host "  [!] Edge not found. Please open the HTML file and print to PDF manually."
}

Write-Host "`nDone!"
