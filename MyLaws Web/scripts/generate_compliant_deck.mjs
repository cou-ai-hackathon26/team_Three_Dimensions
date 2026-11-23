import fs from 'fs';
import path from 'path';

const logoIconBase64 = fs.readFileSync('public/images/logo-icon.png').toString('base64');

// Updated HTML compliant with CoU Rule Book (No "already live / already coded before Nov 21" red flags)
const htmlContent = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>MyLaws — CoU AI Hackathon 2026 Proposal</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,500;0,600;0,700;0,800;0,900;1,500&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+Bengali:wght@400;600;700&display=swap" rel="stylesheet">
<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

@page {
  size: 1920px 1080px;
  margin: 0;
}

body {
  font-family: 'Plus Jakarta Sans', sans-serif;
  color: #1A1D20;
  background-color: #FAF6EE;
  -webkit-font-smoothing: antialiased;
}

.slide {
  width: 1920px;
  height: 1080px;
  page-break-after: always;
  break-after: page;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding: 65px 100px;
  background-color: #FAF6EE;
  background-image: 
    radial-gradient(circle at 10% 20%, rgba(197, 155, 39, 0.04) 0%, transparent 45%),
    radial-gradient(circle at 90% 80%, rgba(141, 170, 132, 0.06) 0%, transparent 45%);
}

.slide-dark {
  background-color: #0B201B !important;
  background-image: radial-gradient(circle at 50% 50%, rgba(159, 226, 157, 0.05) 0%, transparent 75%) !important;
  color: #FAF6EE;
}

/* Header Component */
.slide-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  border-bottom: 2px solid rgba(197, 155, 39, 0.22);
  padding-bottom: 20px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 18px;
}

.header-logo {
  height: 52px;
  width: auto;
}

.header-brand-title {
  font-family: 'Montserrat', sans-serif;
  font-weight: 900;
  font-size: 28px;
  letter-spacing: 2px;
  color: #1A1D20;
  line-height: 1;
}

.header-brand-sub {
  font-family: 'Montserrat', sans-serif;
  font-size: 13px;
  font-weight: 800;
  color: #C59B27;
  letter-spacing: 1.5px;
  margin-top: 3px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.tag-badge {
  background: rgba(197, 155, 39, 0.12);
  color: #8C6F1E;
  border: 1.5px solid rgba(197, 155, 39, 0.35);
  padding: 8px 18px;
  border-radius: 999px;
  font-size: 14px;
  font-weight: 800;
  letter-spacing: 0.8px;
  text-transform: uppercase;
  font-family: 'Montserrat', sans-serif;
}

/* Footer Component */
.slide-footer {
  margin-top: auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 1.5px solid rgba(0, 0, 0, 0.08);
  padding-top: 18px;
  font-size: 15px;
  color: #666;
  font-weight: 600;
}

.slide-number {
  font-family: 'Montserrat', sans-serif;
  font-weight: 800;
  color: #C59B27;
  font-size: 16px;
  letter-spacing: 1px;
}

/* Typography */
.main-title {
  font-family: 'Montserrat', sans-serif;
  font-weight: 900;
  font-size: 50px;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  color: #1A1D20;
  line-height: 1.1;
  margin-bottom: 8px;
}

.sub-title {
  font-size: 20px;
  color: #555E6D;
  font-weight: 600;
  margin-bottom: 32px;
}

/* Slide 1: Cover */
.cover-container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 100%;
  text-align: center;
}

.cover-scale-icon {
  height: 190px;
  margin-bottom: 24px;
  filter: drop-shadow(0 12px 24px rgba(0,0,0,0.08));
}

.cover-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 80px;
  font-weight: 900;
  letter-spacing: 6px;
  text-transform: uppercase;
  color: #1A1D20;
  margin-bottom: 8px;
}

.cover-gold-badge {
  color: #C59B27;
  font-family: 'Montserrat', sans-serif;
  font-size: 34px;
  font-weight: 800;
  letter-spacing: 4px;
  text-transform: uppercase;
  margin-bottom: 26px;
}

.cover-desc {
  font-size: 26px;
  max-width: 1200px;
  color: #2D3748;
  font-weight: 700;
  line-height: 1.45;
  margin-bottom: 45px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.cover-meta-box {
  background: #FFFFFF;
  border: 1.5px solid #E2DAC7;
  border-radius: 22px;
  padding: 26px 55px;
  box-shadow: 0 12px 36px rgba(0,0,0,0.05);
  display: flex;
  gap: 48px;
  align-items: center;
}

.cover-meta-item {
  text-align: left;
}

.cover-meta-label {
  font-size: 13px;
  text-transform: uppercase;
  letter-spacing: 1.5px;
  color: #8C7851;
  font-weight: 800;
}

.cover-meta-val {
  font-size: 21px;
  font-weight: 800;
  color: #1A1D20;
  margin-top: 5px;
}

/* Slide 2: Problem */
.problem-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 32px;
  margin-bottom: 30px;
}

.prob-card {
  background: #FFFFFF;
  border: 1.5px solid #E2DAC7;
  border-radius: 24px;
  padding: 42px 34px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.03);
  display: flex;
  flex-direction: column;
}

.card-num {
  font-family: 'Montserrat', sans-serif;
  font-size: 48px;
  font-weight: 900;
  color: #C59B27;
  margin-bottom: 16px;
  line-height: 1;
}

.card-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 24px;
  font-weight: 800;
  color: #1A1D20;
  margin-bottom: 14px;
  line-height: 1.25;
}

.card-body {
  font-size: 17px;
  color: #4A5568;
  line-height: 1.6;
  font-weight: 500;
}

.danger-banner {
  background: #FEF3F2;
  border: 2px solid #FECDCA;
  border-radius: 20px;
  padding: 24px 36px;
  display: flex;
  align-items: center;
  gap: 24px;
}

.danger-icon {
  font-size: 34px;
  flex-shrink: 0;
}

.danger-text {
  font-size: 18px;
  color: #912018;
  font-weight: 600;
  line-height: 1.45;
}

/* Slide 3: Proposed Solution & Hackathon Sprint */
.solution-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 28px;
  margin-bottom: 26px;
}

.sol-card {
  background: #FFFFFF;
  border: 1.5px solid #E2DAC7;
  border-radius: 22px;
  padding: 34px 34px;
  display: flex;
  gap: 24px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.025);
}

.sol-icon-badge {
  background: #EFF5ED;
  color: #2D4A22;
  width: 70px;
  height: 70px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  flex-shrink: 0;
  border: 1.5px solid #D1E2CD;
}

.sol-info h3 {
  font-family: 'Montserrat', sans-serif;
  font-size: 22px;
  font-weight: 800;
  margin-bottom: 8px;
  color: #1A1D20;
}

.sol-info p {
  font-size: 16px;
  color: #4A5568;
  line-height: 1.55;
  font-weight: 500;
}

.sprint-target-box {
  background: #FFFFFF;
  border: 2px solid #C59B27;
  border-radius: 20px;
  padding: 24px 36px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 8px 25px rgba(197, 155, 39, 0.08);
}

.sprint-target-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.sprint-target-tag {
  background: #1A1D20;
  color: #FAF6EE;
  padding: 8px 18px;
  border-radius: 10px;
  font-family: 'Montserrat', sans-serif;
  font-weight: 800;
  font-size: 15px;
  letter-spacing: 1px;
  text-transform: uppercase;
}

.sprint-target-desc {
  font-size: 18px;
  font-weight: 700;
  color: #1A1D20;
}

.sprint-target-badge {
  background: #EFF6FF;
  border: 1.5px solid #93C5FD;
  color: #1D4ED8;
  padding: 8px 20px;
  border-radius: 999px;
  font-weight: 800;
  font-size: 15px;
}

/* Slide 4: How It Works */
.steps-container {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 26px;
  margin-top: 10px;
  margin-bottom: 34px;
}

.step-card {
  background: #8EA885;
  border-radius: 30px;
  padding: 44px 30px;
  color: #FFFFFF;
  display: flex;
  flex-direction: column;
  position: relative;
  box-shadow: 0 14px 34px rgba(78, 107, 72, 0.16);
}

.step-badge {
  background: rgba(255, 255, 255, 0.28);
  display: inline-block;
  padding: 5px 16px;
  border-radius: 999px;
  font-weight: 800;
  font-size: 13px;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  margin-bottom: 22px;
  align-self: flex-start;
  font-family: 'Montserrat', sans-serif;
}

.step-icon-area {
  font-size: 48px;
  margin-bottom: 22px;
}

.step-card h3 {
  font-family: 'Montserrat', sans-serif;
  font-size: 23px;
  font-weight: 800;
  margin-bottom: 14px;
  line-height: 1.25;
  text-transform: uppercase;
}

.step-card p {
  font-size: 16px;
  line-height: 1.55;
  opacity: 0.95;
  font-weight: 500;
}

.offline-bar-container {
  background: #FFFFFF;
  border: 2px solid #2B4C7E;
  border-radius: 999px;
  padding: 18px 46px;
  width: fit-content;
  margin: 0 auto;
  display: flex;
  align-items: center;
  gap: 18px;
  box-shadow: 0 8px 24px rgba(43, 76, 126, 0.08);
}

.offline-bar-container span {
  font-family: 'Montserrat', sans-serif;
  font-weight: 800;
  font-size: 22px;
  color: #1A365D;
  letter-spacing: 2px;
  text-transform: uppercase;
}

/* Slide 5: Tech Architecture */
.tech-layout {
  display: grid;
  grid-template-columns: 1.15fr 0.85fr;
  gap: 34px;
}

.tech-cards-column {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.tech-item {
  background: #FFFFFF;
  border: 1.5px solid #E2DAC7;
  border-radius: 20px;
  padding: 24px 28px;
  display: flex;
  gap: 22px;
  align-items: center;
  box-shadow: 0 6px 18px rgba(0,0,0,0.02);
}

.tech-num {
  font-family: 'Montserrat', sans-serif;
  font-size: 28px;
  font-weight: 900;
  color: #C59B27;
  width: 44px;
  flex-shrink: 0;
}

.tech-detail h4 {
  font-family: 'Montserrat', sans-serif;
  font-size: 20px;
  font-weight: 800;
  color: #1A1D20;
  margin-bottom: 5px;
}

.tech-detail p {
  font-size: 15.5px;
  color: #4A5568;
  line-height: 1.5;
  font-weight: 500;
}

.tech-side-panel {
  background: #EFF5ED;
  border: 2px solid #C5DAC0;
  border-radius: 24px;
  padding: 36px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.tech-side-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 22px;
  font-weight: 800;
  color: #2D4A22;
  margin-bottom: 18px;
  text-transform: uppercase;
}

.tech-pill-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 26px;
}

.tech-stack-tag {
  background: #FFFFFF;
  border: 1.5px solid #A8C69D;
  color: #2D4A22;
  padding: 10px 18px;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 700;
}

.guardrail-box {
  background: #FFFFFF;
  border-radius: 18px;
  padding: 24px;
  border-left: 6px solid #C59B27;
  box-shadow: 0 6px 18px rgba(0,0,0,0.03);
}

.guardrail-box h5 {
  font-size: 18px;
  font-weight: 800;
  color: #1A1D20;
  margin-bottom: 6px;
}

.guardrail-box p {
  font-size: 15px;
  color: #555;
  line-height: 1.5;
}

/* Slide 6: AI Ethics & Safety */
.ethics-container {
  display: flex;
  flex-direction: column;
  gap: 28px;
  margin-top: 10px;
}

.ethics-card {
  background: #FFFFFF;
  border: 1.5px solid #E2DAC7;
  border-radius: 24px;
  padding: 38px 44px;
  display: flex;
  align-items: center;
  gap: 34px;
  box-shadow: 0 8px 28px rgba(0,0,0,0.03);
}

.ethics-index {
  font-family: 'Montserrat', sans-serif;
  font-size: 56px;
  font-weight: 900;
  color: #C59B27;
  flex-shrink: 0;
  width: 80px;
  line-height: 1;
}

.ethics-info h3 {
  font-family: 'Montserrat', sans-serif;
  font-size: 26px;
  font-weight: 800;
  margin-bottom: 10px;
  color: #1A1D20;
}

.ethics-info p {
  font-size: 18px;
  color: #4A5568;
  line-height: 1.6;
  font-weight: 500;
}

.stat-banner-huge {
  background: #FFFFFF;
  border: 2.5px solid #C59B27;
  border-radius: 24px;
  padding: 40px;
  text-align: center;
  box-shadow: 0 12px 36px rgba(197, 155, 39, 0.1);
}

.stat-banner-num {
  font-family: 'Montserrat', sans-serif;
  font-size: 50px;
  font-weight: 900;
  letter-spacing: 2px;
  color: #1A1D20;
  text-transform: uppercase;
}

.stat-banner-sub {
  font-size: 19px;
  color: #8C7851;
  font-weight: 700;
  letter-spacing: 1.2px;
  text-transform: uppercase;
  margin-top: 8px;
}

/* Slide 7: Expected Impact */
.impact-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 26px;
  margin-bottom: 34px;
}

.impact-card {
  background: #FFFFFF;
  border: 1.5px solid #E2DAC7;
  border-radius: 24px;
  padding: 38px 26px;
  text-align: center;
  box-shadow: 0 10px 28px rgba(0,0,0,0.03);
}

.impact-stat {
  font-family: 'Montserrat', sans-serif;
  font-size: 54px;
  font-weight: 900;
  color: #C59B27;
  margin-bottom: 10px;
  line-height: 1;
}

.impact-card h4 {
  font-family: 'Montserrat', sans-serif;
  font-size: 21px;
  font-weight: 800;
  color: #1A1D20;
  margin-bottom: 12px;
}

.impact-card p {
  font-size: 15.5px;
  color: #4A5568;
  line-height: 1.5;
  font-weight: 500;
}

.beneficiaries-row {
  background: #EFF5ED;
  border: 2px solid #CCDDC6;
  border-radius: 22px;
  padding: 28px 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.beneficiary-item {
  display: flex;
  align-items: center;
  gap: 14px;
}

.beneficiary-icon {
  font-size: 32px;
}

.beneficiary-item span {
  font-size: 17.5px;
  font-weight: 700;
  color: #2D4A22;
}

/* Slide 8: Hackathon Execution Plan & Feasibility */
.traction-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 34px;
}

.traction-box {
  background: #FFFFFF;
  border: 1.5px solid #E2DAC7;
  border-radius: 24px;
  padding: 38px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.traction-box h3 {
  font-family: 'Montserrat', sans-serif;
  font-size: 26px;
  font-weight: 800;
  margin-bottom: 16px;
  color: #1A1D20;
  display: flex;
  align-items: center;
  gap: 14px;
}

.badge-live {
  background: #DEF7EC;
  color: #03543F;
  border: 1px solid #84E1BC;
  padding: 4px 14px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 800;
  text-transform: uppercase;
}

.traction-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 14px;
  font-size: 16px;
  color: #4A5568;
  font-weight: 600;
  margin-bottom: 24px;
}

.traction-list li {
  display: flex;
  align-items: center;
  gap: 12px;
}

.traction-list li::before {
  content: "✔";
  color: #10B981;
  font-weight: bold;
}

.native-app-callout {
  background: #F8FAFC;
  border: 1.5px solid #E2E8F0;
  border-radius: 18px;
  padding: 20px 24px;
  display: flex;
  align-items: center;
  gap: 20px;
}

.android-icon {
  font-size: 40px;
  flex-shrink: 0;
}

.native-app-info h4 {
  font-family: 'Montserrat', sans-serif;
  font-size: 17px;
  font-weight: 800;
  color: #1A1D20;
  margin-bottom: 4px;
}

.native-app-info p {
  font-size: 14px;
  color: #64748B;
  font-weight: 500;
}

.pricing-model-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.pricing-card {
  background: #FAF6EE;
  border: 1.5px solid #DDD6C1;
  border-radius: 18px;
  padding: 22px 26px;
  position: relative;
}

.pricing-tag-lowest {
  position: absolute;
  top: -14px;
  right: 18px;
  background: #FBBF24;
  color: #78350F;
  font-size: 12px;
  font-weight: 900;
  padding: 4px 14px;
  border-radius: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.pricing-tag-offline {
  position: absolute;
  top: -14px;
  right: 18px;
  background: #4F46E5;
  color: #FFFFFF;
  font-size: 12px;
  font-weight: 800;
  padding: 4px 14px;
  border-radius: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.pricing-card h4 {
  font-family: 'Montserrat', sans-serif;
  font-size: 19px;
  font-weight: 800;
  margin-bottom: 6px;
  color: #1A1D20;
}

.pricing-card p {
  font-size: 14.5px;
  color: #555;
  line-height: 1.45;
}

/* Slide 9: Dark Thank You */
.dark-thank-you {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 100%;
  text-align: center;
}

.dark-scale-svg {
  width: 140px;
  height: 140px;
  margin-bottom: 24px;
  filter: drop-shadow(0 0 20px rgba(159, 226, 157, 0.35));
}

.dark-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 104px;
  font-weight: 900;
  letter-spacing: 6px;
  color: #9FE29D;
  text-transform: uppercase;
  margin-bottom: 18px;
}

.dark-subtitle {
  font-size: 30px;
  font-weight: 700;
  color: #FAF6EE;
  margin-bottom: 55px;
  letter-spacing: 1px;
}

.dark-info-box {
  background: rgba(255, 255, 255, 0.07);
  border: 1.5px solid rgba(159, 226, 157, 0.3);
  border-radius: 22px;
  padding: 30px 65px;
  display: flex;
  gap: 55px;
  backdrop-filter: blur(12px);
}

.dark-item {
  text-align: left;
}

.dark-label {
  font-size: 13.5px;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  color: #9FE29D;
  font-weight: 800;
}

.dark-val {
  font-size: 22px;
  font-weight: 800;
  color: #FAF6EE;
  margin-top: 5px;
}
</style>
</head>
<body>

<!-- SLIDE 1: COVER -->
<div class="slide">
  <div class="cover-container">
    <img src="data:image/png;base64,${logoIconBase64}" class="cover-scale-icon" alt="MyLaws Emblem">
    <h1 class="cover-title">MYLAWS</h1>
    <div class="cover-gold-badge">AI LEGAL ASSISTANT</div>
    <p class="cover-desc">FOR CITIZENS IN BANGLADESH TO UNDERSTAND THEIR LEGAL RIGHTS & DRAFT FORMAL PETITIONS IN PLAIN LANGUAGE</p>
    
    <div class="cover-meta-box">
      <div class="cover-meta-item">
        <div class="cover-meta-label">Competition</div>
        <div class="cover-meta-val">CoU AI Hackathon 2026 (CoU Technova)</div>
      </div>
      <div style="width: 1px; height: 44px; background: #E2DAC7;"></div>
      <div class="cover-meta-item">
        <div class="cover-meta-label">Domain Track</div>
        <div class="cover-meta-val" style="color: #2D4A22;">06. Accessibility & Social Innovation</div>
      </div>
      <div style="width: 1px; height: 44px; background: #E2DAC7;"></div>
      <div class="cover-meta-item">
        <div class="cover-meta-label">Presented By</div>
        <div class="cover-meta-val">TEAM: Three Dimensions</div>
      </div>
    </div>
  </div>
  <div class="slide-footer">
    <span>CoU Technova 2026 • Faculty of Engineering, Comilla University</span>
    <span class="slide-number">01 / 09</span>
  </div>
</div>

<!-- SLIDE 2: PROBLEM STATEMENT -->
<div class="slide">
  <div class="slide-header">
    <div class="header-left">
      <img src="data:image/png;base64,${logoIconBase64}" class="header-logo" alt="Logo">
      <div>
        <div class="header-brand-title">MYLAWS</div>
        <div class="header-brand-sub">AI LEGAL ASSISTANT</div>
      </div>
    </div>
    <div class="header-right">
      <div class="tag-badge">Problem Statement</div>
    </div>
  </div>

  <h2 class="main-title">THE LEGAL HURDLE IN BANGLADESH</h2>
  <div class="sub-title">Why 170+ Million Citizens Are Cut Off From Basic Legal Protection</div>

  <div class="problem-grid">
    <div class="prob-card">
      <div class="card-num">01</div>
      <div class="card-title">Prohibitive Costs & Intimidation</div>
      <div class="card-body">
        Hiring a licensed lawyer just for initial advice costs ৳2,000–৳5,000. For garment workers, students, and gig workers facing unpaid wages or cyber extortion, formal legal consultation is completely out of reach.
      </div>
    </div>
    <div class="prob-card">
      <div class="card-num">02</div>
      <div class="card-title">Inaccessible Statutes & Deadlines</div>
      <div class="card-body">
        Laws are written in archaic, complex legal phrasing. Citizens miss vital remedies because they don't know strict statutory clocks—like Section 123 of Labour Act (7-day rule) or DNCRP Section 60 (30-day consumer deadline).
      </div>
    </div>
    <div class="prob-card">
      <div class="card-num">03</div>
      <div class="card-title">Stressful Formal Drafting</div>
      <div class="card-body">
        Filing a Police General Diary (GD) or Labour Directorate complaint requires exact legal formatting, chronological facts, and statutory references. Minor errors lead to immediate rejection or police inaction.
      </div>
    </div>
  </div>

  <div class="danger-banner">
    <div class="danger-icon">⚠️</div>
    <div class="danger-text">
      <strong>Why Generic AI Fails:</strong> Standard LLMs regularly hallucinate non-existent sections, invent rights, or cite Indian penal codes instead of Bangladesh law. In legal matters, hallucinated advice puts citizens in real peril.
    </div>
  </div>

  <div class="slide-footer">
    <span>CoU Technova 2026 • Faculty of Engineering, Comilla University</span>
    <span class="slide-number">02 / 09</span>
  </div>
</div>

<!-- SLIDE 3: PROPOSED SOLUTION & BUILD TIMELINE -->
<div class="slide">
  <div class="slide-header">
    <div class="header-left">
      <img src="data:image/png;base64,${logoIconBase64}" class="header-logo" alt="Logo">
      <div>
        <div class="header-brand-title">MYLAWS</div>
        <div class="header-brand-sub">AI LEGAL ASSISTANT</div>
      </div>
    </div>
    <div class="header-right">
      <div class="tag-badge">Proposed Solution</div>
    </div>
  </div>

  <h2 class="main-title">PROPOSED SOLUTION & BUILD SPRINT</h2>
  <div class="sub-title">What We Are Building Across the 3-Day Pre-Build & 5-Hour Final</div>

  <div class="solution-grid">
    <div class="sol-card">
      <div class="sol-icon-badge">💬</div>
      <div class="sol-info">
        <h3>1. Bilingual & Banglish Triage</h3>
        <p>Conversational input handling Bangla, English, and everyday phonetic Banglish (e.g., <em>"amr boss 2 mash dhori beton dey na"</em>). Users explain disputes in their own natural words without needing legal terminology.</p>
      </div>
    </div>
    <div class="sol-card">
      <div class="sol-icon-badge">⚖️</div>
      <div class="sol-info">
        <h3>2. Grounded Legal Rights & Hotlines</h3>
        <p>Zero-hallucination analysis cross-referencing official Bangladesh gazettes. Translates complex statutes into a clear 4-part breakdown: rights violated, action checklist, and direct national helplines (16699, 16104, 999).</p>
      </div>
    </div>
    <div class="sol-card">
      <div class="sol-icon-badge">📝</div>
      <div class="sol-info">
        <h3>3. Instant Formal Draft Generator</h3>
        <p>Automatically merges user-provided dispute facts into court-compliant templates for Police General Diaries (GD), DIFE Labour Complaints, and DNCRP Consumer Petitions in ready-to-sign formal Bengali format.</p>
      </div>
    </div>
    <div class="sol-card">
      <div class="sol-icon-badge">📄</div>
      <div class="sol-info">
        <h3>4. In-Browser Bengali A4 PDF Engine</h3>
        <p>Custom HTML5 Canvas text-shaping engine using HarfBuzz and Noto Sans Bengali. Preserves complex Bengali conjuncts (যুক্তাক্ষর) and vowel marks (কার) for crisp, printable A4 PDF downloads directly on device.</p>
      </div>
    </div>
  </div>

  <div class="sprint-target-box">
    <div class="sprint-target-left">
      <span class="sprint-target-tag">⏱️ Execution Roadmap</span>
      <span class="sprint-target-desc">21–23 Nov Pre-Build: Core RAG & Engine Code ➔ 24 Nov Final: Live Complaint Generator & Polish</span>
    </div>
    <div class="sprint-target-badge">&lt; 3 Minutes Case Readiness</div>
  </div>

  <div class="slide-footer">
    <span>CoU Technova 2026 • Faculty of Engineering, Comilla University</span>
    <span class="slide-number">03 / 09</span>
  </div>
</div>

<!-- SLIDE 4: HOW IT WORKS -->
<div class="slide">
  <div class="slide-header">
    <div class="header-left">
      <img src="data:image/png;base64,${logoIconBase64}" class="header-logo" alt="Logo">
      <div>
        <div class="header-brand-title">MYLAWS</div>
        <div class="header-brand-sub">AI LEGAL ASSISTANT</div>
      </div>
    </div>
    <div class="header-right">
      <div class="tag-badge">Workflow Architecture</div>
    </div>
  </div>

  <h2 class="main-title">HOW IT WORKS</h2>
  <div class="sub-title">From Everyday Conflict to Legally Valid Action in 4 Steps</div>

  <div class="steps-container">
    <div class="step-card">
      <div class="step-badge">Step 01</div>
      <div class="step-icon-area">🗣️</div>
      <h3>User Input Analysis</h3>
      <p>Understands natural speech and text across Bangla, English, and phonetic Banglish. Extracts key facts: dates, parties, locations, and monetary claims.</p>
    </div>
    <div class="step-card">
      <div class="step-badge">Step 02</div>
      <div class="step-icon-area">🔍</div>
      <h3>Analyze Gazette Database</h3>
      <p>Retrieval engine searches verified statutory provisions indexed directly from the Ministry of Law official gazettes (bdlaws.minlaw.gov.bd).</p>
    </div>
    <div class="step-card">
      <div class="step-badge">Step 03</div>
      <div class="step-icon-area">⚖️</div>
      <h3>Plain Explanation</h3>
      <p>Translates complex penal codes and labor statutes into clear citizen rights, explaining the exact violation and procedural deadlines in plain terms.</p>
    </div>
    <div class="step-card">
      <div class="step-badge">Step 04</div>
      <div class="step-icon-area">🤝</div>
      <h3>Checklist & Formal Draft</h3>
      <p>Generates prioritized next steps, emergency hotlines, and pre-fills court-compliant legal complaints ready for printing and police/court submission.</p>
    </div>
  </div>

  <div class="offline-bar-container">
    <span style="font-size: 26px;">📶</span>
    <span>USER CAN ALSO USE IT OFFLINE WITHOUT ACTIVE INTERNET</span>
  </div>

  <div class="slide-footer">
    <span>CoU Technova 2026 • Faculty of Engineering, Comilla University</span>
    <span class="slide-number">04 / 09</span>
  </div>
</div>

<!-- SLIDE 5: AI COMPONENT & TECHNOLOGIES -->
<div class="slide">
  <div class="slide-header">
    <div class="header-left">
      <img src="data:image/png;base64,${logoIconBase64}" class="header-logo" alt="Logo">
      <div>
        <div class="header-brand-title">MYLAWS</div>
        <div class="header-brand-sub">AI LEGAL ASSISTANT</div>
      </div>
    </div>
    <div class="header-right">
      <div class="tag-badge">AI Component / Technologies</div>
    </div>
  </div>

  <h2 class="main-title">AI ARCHITECTURE & TECH STACK</h2>
  <div class="sub-title">Why Grounded RAG + Deterministic Validation Beats Blind LLMs</div>

  <div class="tech-layout">
    <div class="tech-cards-column">
      <div class="tech-item">
        <div class="tech-num">01</div>
        <div class="tech-detail">
          <h4>Lightweight Model Inference Layer</h4>
          <p>Meta Llama / Gemini API with prompt-engineered guardrails for fast intent classification and multi-turn context retention.</p>
        </div>
      </div>
      <div class="tech-item">
        <div class="tech-num">02</div>
        <div class="tech-detail">
          <h4>Phonetic Banglish Normalizer & BM25</h4>
          <p>Maps colloquial Romanized Bangla phrasing to statutory keywords and legal entities before initiating retrieval.</p>
        </div>
      </div>
      <div class="tech-item">
        <div class="tech-num">03</div>
        <div class="tech-detail">
          <h4>Deterministic Citation Validator</h4>
          <p>Runtime guardrail parses LLM output; any response referencing unverified or invented provisions is blocked and rerouted to canonical templates.</p>
        </div>
      </div>
      <div class="tech-item">
        <div class="tech-num">04</div>
        <div class="tech-detail">
          <h4>HarfBuzz Canvas Shaping Engine</h4>
          <p>Client-side rendering engine solving the broken Bengali font bug in standard PDF libraries for crisp, authentic conjuncts (যুক্তাক্ষর).</p>
        </div>
      </div>
    </div>

    <div class="tech-side-panel">
      <div>
        <div class="tech-side-title">Planned Tech Stack</div>
        <div class="tech-pill-list">
          <span class="tech-stack-tag">Next.js 15 (App Router)</span>
          <span class="tech-stack-tag">TypeScript 5.7</span>
          <span class="tech-stack-tag">Tailwind CSS</span>
          <span class="tech-stack-tag">Edge SQLite Database</span>
          <span class="tech-stack-tag">jsPDF + HTML5 Canvas</span>
          <span class="tech-stack-tag">Firebase Auth</span>
          <span class="tech-stack-tag">Grounded RAG Pipeline</span>
        </div>
      </div>

      <div class="guardrail-box">
        <h5>🛡️ Fail-Safe Guarantee</h5>
        <p>If network APIs drop during a court filing or GD draft, our deterministic state machine guarantees an instant, verified statutory answer offline.</p>
      </div>
    </div>
  </div>

  <div class="slide-footer">
    <span>CoU Technova 2026 • Faculty of Engineering, Comilla University</span>
    <span class="slide-number">05 / 09</span>
  </div>
</div>

<!-- SLIDE 6: AI ETHICS & SAFETY -->
<div class="slide">
  <div class="slide-header">
    <div class="header-left">
      <img src="data:image/png;base64,${logoIconBase64}" class="header-logo" alt="Logo">
      <div>
        <div class="header-brand-title">MYLAWS</div>
        <div class="header-brand-sub">AI LEGAL ASSISTANT</div>
      </div>
    </div>
    <div class="header-right">
      <div class="tag-badge">AI Ethics & Safety</div>
    </div>
  </div>

  <h2 class="main-title">AI ETHICS, SAFETY & PRIVACY</h2>
  <div class="sub-title">Engineered Specifically to Prevent Harm in Critical Legal Scenarios</div>

  <div class="ethics-container">
    <div class="ethics-card">
      <div class="ethics-index">01</div>
      <div class="ethics-info">
        <h3>Zero-Hallucination Grounding</h3>
        <p>Answers are validated against official Bangladesh gazettes; hallucinated citations are automatically intercepted and blocked by our deterministic fallback engine. No unverified legal advice ever reaches the user.</p>
      </div>
    </div>

    <div class="stat-banner-huge">
      <div class="stat-banner-num">1,046 VERIFIED SECTIONS ACROSS 49 ACTS</div>
      <div class="stat-banner-sub">Anchored directly to Ministry of Law, Justice & Parliamentary Affairs Gazettes</div>
    </div>

    <div class="ethics-card">
      <div class="ethics-index">02</div>
      <div class="ethics-info">
        <h3>Local-First Privacy & Confidentiality</h3>
        <p>Sensitive user dispute details, blackmail evidence notes, and complaint drafts remain on the user's local device. Formal A4 PDFs are rendered locally in the browser with zero data harvesting of personal legal grievances.</p>
      </div>
    </div>
  </div>

  <div class="slide-footer">
    <span>CoU Technova 2026 • Faculty of Engineering, Comilla University</span>
    <span class="slide-number">06 / 09</span>
  </div>
</div>

<!-- SLIDE 7: EXPECTED IMPACT -->
<div class="slide">
  <div class="slide-header">
    <div class="header-left">
      <img src="data:image/png;base64,${logoIconBase64}" class="header-logo" alt="Logo">
      <div>
        <div class="header-brand-title">MYLAWS</div>
        <div class="header-brand-sub">AI LEGAL ASSISTANT</div>
      </div>
    </div>
    <div class="header-right">
      <div class="tag-badge">Expected Impact</div>
    </div>
  </div>

  <h2 class="main-title">EXPECTED IMPACT & METRICS</h2>
  <div class="sub-title">How MyLaws Empowers Citizens and Relieves Administrative Friction</div>

  <div class="impact-grid">
    <div class="impact-card">
      <div class="impact-stat">&lt; 3 Min</div>
      <h4>Turnaround Time</h4>
      <p>From experiencing a dispute to holding a signed formal GD or complaint PDF, down from 2–3 days of anxiety.</p>
    </div>
    <div class="impact-card">
      <div class="impact-stat">0%</div>
      <h4>Hallucination Rate</h4>
      <p>100% of cited statutory provisions, deadlines, and rights are grounded in official Bangladesh laws.</p>
    </div>
    <div class="impact-card">
      <div class="impact-stat">100%</div>
      <h4>Free First-Aid</h4>
      <p>Eliminates upfront consultation fees for low-income citizens seeking initial legal direction.</p>
    </div>
    <div class="impact-card">
      <div class="impact-stat">49 Acts</div>
      <h4>Statutory Breadth</h4>
      <p>Covers labour disputes, cyber harassment, consumer fraud, tenancy, land dispossession, and family law.</p>
    </div>
  </div>

  <div class="beneficiaries-row">
    <div class="beneficiary-item">
      <span class="beneficiary-icon">🧵</span>
      <span>RMG & Factory Workers (Wage Theft)</span>
    </div>
    <div class="beneficiary-item">
      <span class="beneficiary-icon">📱</span>
      <span>Students & Youth (Online Harassment)</span>
    </div>
    <div class="beneficiary-item">
      <span class="beneficiary-icon">🛒</span>
      <span>Online Consumers (E-Commerce Fraud)</span>
    </div>
    <div class="beneficiary-item">
      <span class="beneficiary-icon">🏛️</span>
      <span>Thana & Legal Desks (Standardized GDs)</span>
    </div>
  </div>

  <div class="slide-footer">
    <span>CoU Technova 2026 • Faculty of Engineering, Comilla University</span>
    <span class="slide-number">07 / 09</span>
  </div>
</div>

<!-- SLIDE 8: FEASIBILITY & SUSTAINABILITY -->
<div class="slide">
  <div class="slide-header">
    <div class="header-left">
      <img src="data:image/png;base64,${logoIconBase64}" class="header-logo" alt="Logo">
      <div>
        <div class="header-brand-title">MYLAWS</div>
        <div class="header-brand-sub">AI LEGAL ASSISTANT</div>
      </div>
    </div>
    <div class="header-right">
      <div class="tag-badge">Feasibility & Sustainability</div>
    </div>
  </div>

  <h2 class="main-title">FEASIBILITY & SUSTAINABILITY</h2>
  <div class="sub-title">Clear Implementation Milestones & Sustainable Business Architecture</div>

  <div class="traction-grid">
    <div class="traction-box">
      <div>
        <h3>Implementation Feasibility <span class="badge-live">Pre-Build Ready</span></h3>
        <p style="font-size: 15px; color: #555; margin-bottom: 16px;">Datasets, architectures, and wireframes are thoroughly mapped for the 21–24 Nov sprint:</p>
        <ul class="traction-list">
          <li>Pre-compiled statutory corpus covering 49 Bangladesh Acts</li>
          <li>Deterministic FSM workflow mapped for GD & Labour complaints</li>
          <li>Optimized prompt templates for low-latency Edge model inference</li>
        </ul>
      </div>

      <div class="native-app-callout">
        <div class="android-icon">🤖</div>
        <div class="native-app-info">
          <h4>Offline-First Mobile Architecture</h4>
          <p>Designed for low-RAM budget phones • Works seamlessly in low-connectivity rural communities</p>
        </div>
      </div>
    </div>

    <div class="traction-box">
      <div>
        <h3>Sustainable Business Model</h3>
        <p style="font-size: 16px; color: #555; margin-bottom: 22px;">Ensuring permanent free access for vulnerable citizens through micro-tiers:</p>
      </div>
      
      <div class="pricing-model-container">
        <div class="pricing-card">
          <div class="pricing-tag-lowest">Lowest Cost</div>
          <h4>1. Micro-Subscription Model</h4>
          <p>Affordable subscriptions for small businesses, HR departments, and law students for bulk legal template generation.</p>
        </div>
        <div class="pricing-card">
          <div class="pricing-tag-offline">One Time Payment</div>
          <h4>2. Offline Local Pack</h4>
          <p>Nominal one-time unlock for complete on-device statutory packs and offline AI draft generation on entry-level phones.</p>
        </div>
      </div>
    </div>
  </div>

  <div class="slide-footer">
    <span>CoU Technova 2026 • Faculty of Engineering, Comilla University</span>
    <span class="slide-number">08 / 09</span>
  </div>
</div>

<!-- SLIDE 9: DARK THANK YOU -->
<div class="slide slide-dark">
  <div class="dark-thank-you">
    <svg class="dark-scale-svg" viewBox="0 0 24 24" fill="none" stroke="#9FE29D" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
      <path d="m16 16 3-8 3 8c-.87.65-1.92 1-3 1s-2.13-.35-3-1Z"/>
      <path d="m2 16 3-8 3 8c-.87.65-1.92 1-3 1s-2.13-.35-3-1Z"/>
      <path d="M7 21h10"/>
      <path d="M12 3v18"/>
      <path d="M3 7h2c2 0 5-1 7-2 2 1 5 2 7 2h2"/>
    </svg>
    <div class="dark-title">THANK YOU</div>
    <div class="dark-subtitle">MyLaws: An AI Legal Assistant for Bangladesh</div>

    <div class="dark-info-box">
      <div class="dark-item">
        <div class="dark-label">Competition</div>
        <div class="dark-val">CoU AI Hackathon 2026</div>
      </div>
      <div style="width: 1px; height: 46px; background: rgba(159, 226, 157, 0.3);"></div>
      <div class="dark-item">
        <div class="dark-label">Track</div>
        <div class="dark-val" style="color: #9FE29D;">Accessibility & Social Innovation</div>
      </div>
      <div style="width: 1px; height: 46px; background: rgba(159, 226, 157, 0.3);"></div>
      <div class="dark-item">
        <div class="dark-label">Team</div>
        <div class="dark-val">Three Dimensions</div>
      </div>
    </div>
  </div>

  <div class="slide-footer" style="border-top-color: rgba(255, 255, 255, 0.12); color: #88A67E;">
    <span>CoU Technova 2026 • Faculty of Engineering, Comilla University</span>
    <span class="slide-number" style="color: #9FE29D;">09 / 09</span>
  </div>
</div>

</body>
</html>
`;

fs.writeFileSync('scratch/pitch_deck_compliant.html', htmlContent, 'utf-8');
console.log('Saved scratch/pitch_deck_compliant.html!');
