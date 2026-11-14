import React from 'react';

export default function InstituteBuildingIllustration({ className = '', variant = 'full' }) {
  if (variant === 'compact') {
    return (
      <div className={`building-compact-wrapper ${className}`} style={{ width: '100%', maxWidth: '280px', margin: '0 auto' }}>
        <svg viewBox="0 0 300 240" fill="none" xmlns="http://www.w3.org/2000/svg" style={{ width: '100%', height: 'auto', display: 'block' }}>
          <defs>
            <linearGradient id="skyGradC" x1="150" y1="0" x2="150" y2="240" gradientUnits="userSpaceOnUse">
              <stop stopColor="#E0F2FE" />
              <stop stopColor="#F0F9FF" stopOpacity="0.5" />
            </linearGradient>
            <linearGradient id="roofGradC" x1="150" y1="30" x2="150" y2="90" gradientUnits="userSpaceOnUse">
              <stop stopColor="#0284C7" />
              <stop stopColor="#0369A1" />
            </linearGradient>
            <linearGradient id="wallGradC" x1="150" y1="90" x2="150" y2="210" gradientUnits="userSpaceOnUse">
              <stop stopColor="#FFFFFF" />
              <stop stopColor="#E2E8F0" />
            </linearGradient>
          </defs>
          <rect width="300" height="240" rx="16" fill="url(#skyGradC)" />
          {/* Ground */}
          <rect y="200" width="300" height="40" fill="#CBD5E1" />
          <rect y="196" width="300" height="6" fill="#10B981" />
          {/* Steps */}
          <rect x="100" y="190" width="100" height="6" rx="2" fill="#94A3B8" />
          <rect x="110" y="184" width="80" height="6" rx="2" fill="#CBD5E1" />
          {/* Main Building Base */}
          <rect x="50" y="90" width="200" height="94" rx="4" fill="url(#wallGradC)" stroke="#94A3B8" strokeWidth="1.5" />
          {/* Pillars */}
          {[70, 110, 150, 190, 220].map((x, i) => (
            <g key={i}>
              <rect x={x} y="94" width="10" height="90" fill="#F8FAFC" stroke="#CBD5E1" strokeWidth="1" />
              <rect x={x - 2} y="90" width="14" height="4" fill="#94A3B8" />
              <rect x={x - 2} y="180" width="14" height="4" fill="#94A3B8" />
            </g>
          ))}
          {/* Central Pediment Triangle */}
          <polygon points="150,34 60,90 240,90" fill="url(#roofGradC)" />
          {/* Clock in Pediment */}
          <circle cx="150" cy="70" r="12" fill="#FFFFFF" stroke="#0369A1" strokeWidth="2" />
          <line x1="150" y1="70" x2="150" y2="63" stroke="#0F172A" strokeWidth="1.5" strokeLinecap="round" />
          <line x1="150" y1="70" x2="155" y2="70" stroke="#0F172A" strokeWidth="1.5" strokeLinecap="round" />
          {/* Door */}
          <path d="M136 184V146C136 138 164 138 164 146V184H136Z" fill="#0284C7" />
          {/* Windows */}
          <rect x="85" y="110" width="16" height="22" rx="3" fill="#38BDF8" opacity="0.8" />
          <rect x="199" y="110" width="16" height="22" rx="3" fill="#38BDF8" opacity="0.8" />
          <rect x="85" y="145" width="16" height="22" rx="3" fill="#38BDF8" opacity="0.8" />
          <rect x="199" y="145" width="16" height="22" rx="3" fill="#38BDF8" opacity="0.8" />
          {/* Trees */}
          <circle cx="32" cy="180" r="16" fill="#10B981" />
          <rect x="30" y="190" width="4" height="10" fill="#78350F" />
          <circle cx="268" cy="180" r="16" fill="#10B981" />
          <rect x="266" y="190" width="4" height="10" fill="#78350F" />
        </svg>
      </div>
    );
  }

  // Full detailed illustration for Home Page and Large cards
  return (
    <div className={`institute-building-wrapper ${className}`} style={{ width: '100%', maxWidth: '580px', margin: '0 auto' }}>
      <svg
        viewBox="0 0 620 440"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ width: '100%', height: 'auto', display: 'block', borderRadius: '20px' }}
      >
        <defs>
          <linearGradient id="skyGrad" x1="310" y1="0" x2="310" y2="440" gradientUnits="userSpaceOnUse">
            <stop stopColor="#BAE6FD" />
            <stop stopColor="#E0F2FE" />
            <stop stopColor="#F8FAFC" />
          </linearGradient>

          <linearGradient id="sunGlow" x1="510" y1="40" x2="570" y2="100" gradientUnits="userSpaceOnUse">
            <stop stopColor="#FDE047" />
            <stop stopColor="#F59E0B" />
          </linearGradient>

          <linearGradient id="brickWall" x1="310" y1="130" x2="310" y2="350" gradientUnits="userSpaceOnUse">
            <stop stopColor="#F8FAFC" />
            <stop stopColor="#E2E8F0" />
          </linearGradient>

          <linearGradient id="roofPrimary" x1="310" y1="50" x2="310" y2="140" gradientUnits="userSpaceOnUse">
            <stop stopColor="#0284C7" />
            <stop stopColor="#0369A1" />
          </linearGradient>

          <linearGradient id="domeGrad" x1="310" y1="40" x2="310" y2="100" gradientUnits="userSpaceOnUse">
            <stop stopColor="#0EA5E9" />
            <stop stopColor="#0284C7" />
          </linearGradient>

          <filter id="softGlow" x="-10%" y="-10%" width="120%" height="120%" filterUnits="userSpaceOnUse">
            <feDropShadow dx="0" dy="8" stdDeviation="10" floodColor="#0F172A" floodOpacity="0.1" />
          </filter>
        </defs>

        {/* Sky Background */}
        <rect width="620" height="440" rx="20" fill="url(#skyGrad)" />

        {/* Sun */}
        <circle cx="530" cy="70" r="38" fill="url(#sunGlow)" opacity="0.85" />
        <circle cx="530" cy="70" r="48" stroke="#FEF08A" strokeWidth="2" strokeDasharray="4 4" opacity="0.6" />

        {/* Soft Clouds */}
        <path d="M70 65C70 54 79 45 90 45C97 45 103 49 106 54C109 52 113 50 118 50C129 50 138 58 138 68C143 69 148 74 148 80C148 86 142 91 135 91H75C66 91 60 84 60 76C60 70 65 65 70 65Z" fill="#FFFFFF" opacity="0.85" />
        <path d="M220 85C220 76 228 69 237 69C243 69 248 72 251 76C254 74 257 73 261 73C270 73 277 79 277 87C281 88 285 92 285 97C285 102 280 106 274 106H224C217 106 212 100 212 94C212 89 216 85 220 85Z" fill="#FFFFFF" opacity="0.75" />

        {/* Trees in Background */}
        <ellipse cx="65" cy="300" rx="42" ry="55" fill="#059669" />
        <ellipse cx="115" cy="310" rx="35" ry="45" fill="#10B981" />
        <ellipse cx="510" cy="310" rx="38" ry="48" fill="#10B981" />
        <ellipse cx="560" cy="300" rx="42" ry="55" fill="#059669" />

        {/* Main Lawn Ground */}
        <path d="M0 350H620V440H0V350Z" fill="#10B981" />
        <path d="M0 375H620V440H0V375Z" fill="#059669" opacity="0.4" />
        {/* Pathway / Walkway */}
        <polygon points="270,350 350,350 420,440 200,440" fill="#E2E8F0" />
        <polygon points="295,350 325,350 340,440 280,440" fill="#CBD5E1" opacity="0.5" />

        {/* Campus Building Structure */}
        <g filter="url(#softGlow)">
          {/* Side Wings */}
          {/* Left Wing */}
          <rect x="90" y="190" width="130" height="155" fill="#F1F5F9" stroke="#94A3B8" strokeWidth="2" />
          <polygon points="85,190 155,145 225,190" fill="#0369A1" />
          {/* Windows Left Wing */}
          {[0, 1, 2].map((row) => (
            <g key={`lw-${row}`}>
              <rect x="110" y={210 + row * 40} width="22" height="26" rx="4" fill="#38BDF8" stroke="#0284C7" strokeWidth="1" />
              <rect x="145" y={210 + row * 40} width="22" height="26" rx="4" fill="#38BDF8" stroke="#0284C7" strokeWidth="1" />
              <rect x="180" y={210 + row * 40} width="22" height="26" rx="4" fill="#38BDF8" stroke="#0284C7" strokeWidth="1" />
            </g>
          ))}

          {/* Right Wing */}
          <rect x="400" y="190" width="130" height="155" fill="#F1F5F9" stroke="#94A3B8" strokeWidth="2" />
          <polygon points="395,190 465,145 535,190" fill="#0369A1" />
          {/* Windows Right Wing */}
          {[0, 1, 2].map((row) => (
            <g key={`rw-${row}`}>
              <rect x="418" y={210 + row * 40} width="22" height="26" rx="4" fill="#38BDF8" stroke="#0284C7" strokeWidth="1" />
              <rect x="453" y={210 + row * 40} width="22" height="26" rx="4" fill="#38BDF8" stroke="#0284C7" strokeWidth="1" />
              <rect x="488" y={210 + row * 40} width="22" height="26" rx="4" fill="#38BDF8" stroke="#0284C7" strokeWidth="1" />
            </g>
          ))}

          {/* Main Central Building */}
          <rect x="200" y="150" width="220" height="195" fill="url(#brickWall)" stroke="#64748B" strokeWidth="2" />

          {/* Central Pediment Triangle Roof */}
          <polygon points="310,65 190,150 430,150" fill="url(#roofPrimary)" stroke="#0369A1" strokeWidth="2" />

          {/* Central Cupola / Clock Tower */}
          <rect x="280" y="18" width="60" height="48" fill="#F8FAFC" stroke="#0369A1" strokeWidth="2" />
          <path d="M275 18C275 -5 345 -5 345 18H275Z" fill="url(#domeGrad)" />
          {/* Spire & Flag */}
          <line x1="310" y1="-5" x2="310" y2="-22" stroke="#0F172A" strokeWidth="2.5" />
          <polygon points="310,-22 332,-16 310,-10" fill="#EF4444" />

          {/* Clock in Central Pediment */}
          <circle cx="310" cy="118" r="18" fill="#FFFFFF" stroke="#0369A1" strokeWidth="3" />
          <line x1="310" y1="118" x2="310" y2="108" stroke="#0F172A" strokeWidth="2" strokeLinecap="round" />
          <line x1="310" y1="118" x2="318" y2="118" stroke="#0F172A" strokeWidth="2" strokeLinecap="round" />

          {/* Majestic Pillars (Columns) */}
          {[218, 252, 286, 320, 354, 388].map((colX, idx) => (
            <g key={idx}>
              {/* Column Capital */}
              <rect x={colX - 4} y="150" width="22" height="7" rx="1" fill="#CBD5E1" stroke="#94A3B8" strokeWidth="1" />
              {/* Pillar Shaft */}
              <rect x={colX} y="157" width="14" height="175" fill="#FFFFFF" stroke="#CBD5E1" strokeWidth="1.5" />
              {/* Column Base */}
              <rect x={colX - 4} y="332" width="22" height="8" rx="1" fill="#CBD5E1" stroke="#94A3B8" strokeWidth="1" />
            </g>
          ))}

          {/* Main Grand Entrance Arch */}
          <path d="M285 340V270C285 255 335 255 335 270V340H285Z" fill="#0284C7" stroke="#0369A1" strokeWidth="2" />
          {/* Arch details */}
          <line x1="310" y1="262" x2="310" y2="340" stroke="#0369A1" strokeWidth="1.5" />
          <circle cx="304" cy="305" r="3" fill="#FDE047" />
          <circle cx="316" cy="305" r="3" fill="#FDE047" />

          {/* Front Stairs */}
          <rect x="180" y="340" width="260" height="6" rx="2" fill="#E2E8F0" />
          <rect x="195" y="346" width="230" height="6" rx="2" fill="#CBD5E1" />
          <rect x="210" y="352" width="200" height="6" rx="2" fill="#94A3B8" />

          {/* Balcony / Frieze text "INSTITUTE OF EXCELLENCE" */}
          <rect x="200" y="145" width="220" height="10" fill="#0284C7" />
        </g>

        {/* Foreground Modern Elements */}
        {/* Lamp Posts */}
        <g>
          <line x1="160" y1="330" x2="160" y2="375" stroke="#334155" strokeWidth="3" />
          <circle cx="160" cy="326" r="6" fill="#FDE047" />
          <circle cx="160" cy="326" r="10" stroke="#FDE047" strokeWidth="1" opacity="0.5" />

          <line x1="460" y1="330" x2="460" y2="375" stroke="#334155" strokeWidth="3" />
          <circle cx="460" cy="326" r="6" fill="#FDE047" />
          <circle cx="460" cy="326" r="10" stroke="#FDE047" strokeWidth="1" opacity="0.5" />
        </g>
      </svg>
    </div>
  );
}
