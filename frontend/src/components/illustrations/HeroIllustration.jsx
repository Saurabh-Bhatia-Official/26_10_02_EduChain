import React from 'react';

export default function HeroIllustration({ className = '' }) {
  return (
    <div className={`hero-illustration-wrapper ${className}`} style={{ width: '100%', maxWidth: '520px', margin: '0 auto' }}>
      <svg
        viewBox="0 0 540 440"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ width: '100%', height: 'auto', display: 'block' }}
      >
        <defs>
          {/* Gradients */}
          <linearGradient id="bgGlow" x1="270" y1="40" x2="270" y2="400" gradientUnits="userSpaceOnUse">
            <stop stopColor="#E0EDFF" stopOpacity="0.8" />
            <stop stopColor="#F1F6FF" stopOpacity="0.2" />
          </linearGradient>
          
          <linearGradient id="chairGrad" x1="190" y1="180" x2="290" y2="340" gradientUnits="userSpaceOnUse">
            <stop stopColor="#1E68F5" />
            <stop stopColor="#124CB8" />
          </linearGradient>

          <linearGradient id="laptopGrad" x1="210" y1="210" x2="290" y2="280" gradientUnits="userSpaceOnUse">
            <stop stopColor="#1E293B" />
            <stop stopColor="#0F172A" />
          </linearGradient>

          <filter id="softShadow" x="-10%" y="-10%" width="120%" height="130%" filterUnits="userSpaceOnUse">
            <feDropShadow dx="0" dy="8" stdDeviation="12" floodColor="#1E68F5" floodOpacity="0.12" />
          </filter>

          <filter id="cardShadow" x="-20%" y="-20%" width="140%" height="150%" filterUnits="userSpaceOnUse">
            <feDropShadow dx="0" dy="6" stdDeviation="8" floodColor="#0F172A" floodOpacity="0.08" />
          </filter>
        </defs>

        {/* Backdrop Circular Glow */}
        <circle cx="270" cy="220" r="185" fill="url(#bgGlow)" />
        <circle cx="270" cy="220" r="215" stroke="#E2EEFF" strokeWidth="1.5" strokeDasharray="6 6" />

        {/* Floating Bubble/Card Left (Book / Code) */}
        <g filter="url(#cardShadow)">
          <rect x="70" y="160" width="56" height="56" rx="16" fill="#FFFFFF" />
          <circle cx="98" cy="188" r="18" fill="#EEF4FF" />
          {/* Code icon */}
          <path d="M94 184L90 188L94 192M102 184L106 188L102 192" stroke="#1D68F5" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
        </g>

        {/* Floating Bubble/Card Right Top (Certificate/Star) */}
        <g filter="url(#cardShadow)">
          <rect x="420" y="120" width="54" height="54" rx="16" fill="#FFFFFF" />
          <circle cx="447" cy="147" r="18" fill="#FEF3C7" />
          <path d="M447 139L450 144.5L456 145.5L451.5 149.5L453 155.5L447 152.5L441 155.5L442.5 149.5L438 145.5L444 144.5L447 139Z" fill="#F59E0B" />
        </g>

        {/* Floating Graduation Cap (Top Right) */}
        <g transform="translate(365, 55)">
          {/* Cap diamond */}
          <polygon points="45,10 90,26 45,42 0,26" fill="#1D2A44" />
          {/* Skull cap */}
          <path d="M22 31V45C22 54 32 60 45 60C58 60 68 54 68 45V31" fill="#152033" />
          {/* Tassel Button */}
          <circle cx="45" cy="26" r="3.5" fill="#F59E0B" />
          {/* Ribbon & Tassel */}
          <path d="M45 26C55 28 64 36 67 48" stroke="#F59E0B" strokeWidth="2" strokeLinecap="round" />
          <rect x="65" y="47" width="5" height="12" rx="2" fill="#F59E0B" />
        </g>

        {/* Desk Surface & Stand */}
        <g>
          {/* Desk Legs */}
          <rect x="155" y="275" width="8" height="110" rx="4" fill="#94A3B8" />
          <rect x="365" y="275" width="8" height="110" rx="4" fill="#94A3B8" />
          {/* Ground shadow */}
          <ellipse cx="265" cy="385" rx="160" ry="12" fill="#E2E8F0" />
          {/* Desk Top */}
          <rect x="125" y="268" width="280" height="14" rx="7" fill="#FFFFFF" filter="url(#softShadow)" />
          <rect x="125" y="274" width="280" height="4" fill="#E2E8F0" />
        </g>

        {/* Chair Back */}
        <rect x="220" y="165" width="60" height="95" rx="14" fill="url(#chairGrad)" />
        <rect x="215" y="250" width="70" height="12" rx="6" fill="#124CB8" />

        {/* Student Sitting */}
        <g>
          {/* Body / Blue Polo Shirt */}
          <path d="M225 210C225 195 240 190 250 190C260 190 275 195 275 210L278 268H222L225 210Z" fill="#1D68F5" />
          {/* Collar */}
          <polygon points="250,205 242,190 258,190" fill="#E0EDFF" />
          <polygon points="250,205 246,190 250,190" fill="#CBD5E1" />

          {/* Neck */}
          <rect x="244" y="178" width="12" height="16" rx="4" fill="#FDBA74" />

          {/* Head */}
          <ellipse cx="250" cy="165" rx="16" ry="19" fill="#FED7AA" />
          {/* Smile and Ears */}
          <circle cx="233" cy="166" r="3.5" fill="#FED7AA" />
          <circle cx="267" cy="166" r="3.5" fill="#FED7AA" />
          <path d="M246 172C248 174 252 174 254 172" stroke="#C2410C" strokeWidth="1.5" strokeLinecap="round" />
          <circle cx="244" cy="164" r="1.5" fill="#1E293B" />
          <circle cx="256" cy="164" r="1.5" fill="#1E293B" />

          {/* Hair (Modern short cut) */}
          <path d="M233 162C233 148 242 144 250 144C260 144 268 149 268 162C268 164 265 158 262 157C259 156 255 159 250 157C245 155 240 158 236 158C234 158 233 160 233 162Z" fill="#1E293B" />

          {/* Arms reaching for laptop */}
          <path d="M225 218C220 232 230 252 242 258" stroke="#1D68F5" strokeWidth="10" strokeLinecap="round" />
          <path d="M275 218C280 232 270 252 258 258" stroke="#1D68F5" strokeWidth="10" strokeLinecap="round" />
          {/* Hands */}
          <circle cx="243" cy="258" r="4.5" fill="#FED7AA" />
          <circle cx="257" cy="258" r="4.5" fill="#FED7AA" />
        </g>

        {/* Modern Laptop on Desk */}
        <g>
          {/* Laptop Base */}
          <rect x="230" y="260" width="48" height="6" rx="2" fill="#334155" />
          {/* Laptop Screen Open at Angle */}
          <path d="M236 215L272 215L276 260L232 260Z" fill="url(#laptopGrad)" />
          {/* Screen Display Glass */}
          <path d="M238 217L270 217L274 257L234 257Z" fill="#0EA5E9" />
          {/* Glowing Code / LMS Interface lines */}
          <rect x="242" y="224" width="16" height="3" rx="1.5" fill="#FFFFFF" opacity="0.9" />
          <rect x="242" y="230" width="22" height="2" rx="1" fill="#BAE6FD" opacity="0.8" />
          <rect x="242" y="235" width="14" height="2" rx="1" fill="#BAE6FD" opacity="0.8" />
          <rect x="242" y="240" width="18" height="2" rx="1" fill="#38BDF8" opacity="0.7" />
          {/* Mini logo glow on back */}
          <circle cx="254" cy="235" r="3" fill="#FFFFFF" opacity="0.25" />
        </g>

        {/* Stack of Colorful Books on Desk (Right side) */}
        <g transform="translate(325, 218)">
          {/* Book 1 (Bottom - Blue) */}
          <rect x="0" y="38" width="46" height="12" rx="3" fill="#2563EB" />
          <rect x="6" y="41" width="36" height="6" fill="#F8FAFC" />
          <rect x="2" y="38" width="4" height="12" rx="1" fill="#1D4ED8" />

          {/* Book 2 (Middle - Red/Coral) */}
          <rect x="3" y="25" width="42" height="12" rx="3" fill="#EF4444" />
          <rect x="8" y="28" width="34" height="6" fill="#F8FAFC" />
          <rect x="4" y="25" width="4" height="12" rx="1" fill="#DC2626" />

          {/* Book 3 (Top - Emerald Green) */}
          <rect x="7" y="13" width="36" height="11" rx="3" fill="#10B981" />
          <rect x="11" y="16" width="28" height="5" fill="#F8FAFC" />
          <rect x="8" y="13" width="4" height="11" rx="1" fill="#059669" />
        </g>

        {/* Small Coffee Cup on Desk (Left side) */}
        <g transform="translate(165, 246)">
          <rect x="0" y="6" width="14" height="16" rx="3" fill="#FFFFFF" stroke="#CBD5E1" strokeWidth="1" />
          <path d="M14 10C17 10 17 16 14 16" stroke="#94A3B8" strokeWidth="1.5" strokeLinecap="round" />
          {/* Steam */}
          <path d="M4 2C4 0 7 0 7 -2" stroke="#94A3B8" strokeWidth="1" strokeLinecap="round" opacity="0.6" />
          <path d="M9 3C9 1 12 1 12 -1" stroke="#94A3B8" strokeWidth="1" strokeLinecap="round" opacity="0.6" />
        </g>

        {/* Decorative sparkles */}
        <circle cx="160" cy="110" r="3" fill="#60A5FA" />
        <circle cx="390" cy="220" r="4" fill="#FBBF24" />
        <circle cx="330" cy="100" r="2.5" fill="#818CF8" />
      </svg>
    </div>
  );
}
