import React from 'react';

export default function StudentIllustration({ className = '' }) {
  return (
    <div className={`student-illustration-wrapper ${className}`} style={{ width: '100%', maxWidth: '420px', margin: '0 auto' }}>
      <svg
        viewBox="0 0 400 480"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ width: '100%', height: 'auto', display: 'block' }}
      >
        <defs>
          <linearGradient id="studentBgGlow" x1="200" y1="50" x2="200" y2="440" gradientUnits="userSpaceOnUse">
            <stop stopColor="#E2EEFF" stopOpacity="0.75" />
            <stop stopColor="#F8FAFC" stopOpacity="0.1" />
          </linearGradient>

          <filter id="tileShadow" x="-20%" y="-20%" width="140%" height="150%" filterUnits="userSpaceOnUse">
            <feDropShadow dx="0" dy="8" stdDeviation="10" floodColor="#1D68F5" floodOpacity="0.1" />
          </filter>
        </defs>

        {/* Ambient Circular Glow */}
        <circle cx="200" cy="240" r="170" fill="url(#studentBgGlow)" />
        <circle cx="200" cy="240" r="190" stroke="#DBEAFE" strokeWidth="1.5" strokeDasharray="6 6" />

        {/* Floating Tile 1: Books (Left Middle) */}
        <g filter="url(#tileShadow)" transform="translate(30, 200)">
          <rect width="52" height="52" rx="16" fill="#FFFFFF" />
          <rect x="10" y="10" width="32" height="32" rx="10" fill="#EEF4FF" />
          {/* Book Icon */}
          <path d="M18 20C21 19 25 20 26 22C27 20 31 19 34 20V32C31 31 27 32 26 34C25 32 21 31 18 32V20Z" stroke="#1D68F5" strokeWidth="2" strokeLinejoin="round" />
        </g>

        {/* Floating Tile 2: Pencil / Edit (Right Middle) */}
        <g filter="url(#tileShadow)" transform="translate(320, 180)">
          <rect width="50" height="50" rx="16" fill="#FFFFFF" />
          <rect x="9" y="9" width="32" height="32" rx="10" fill="#FEF3C7" />
          {/* Lightbulb / Pencil Icon */}
          <path d="M22 31L30 23L33 26L25 34L21 35L22 31Z" fill="#F59E0B" />
        </g>

        {/* Floating Tile 3: Code / Degree (Top Left) */}
        <g filter="url(#tileShadow)" transform="translate(50, 80)">
          <rect width="48" height="48" rx="14" fill="#FFFFFF" />
          <circle cx="24" cy="24" r="15" fill="#E0F2FE" />
          <path d="M21 21L18 24L21 27M27 21L30 24L27 27" stroke="#0284C7" strokeWidth="2" strokeLinecap="round" />
        </g>

        {/* Ground Soft Shadow */}
        <ellipse cx="200" cy="445" rx="110" ry="12" fill="#E2E8F0" />

        {/* Student Figure */}
        {/* Backpack on Back (behind body) */}
        <rect x="120" y="210" width="46" height="90" rx="18" fill="#1E293B" />
        <rect x="124" y="220" width="12" height="60" rx="6" fill="#334155" />

        {/* Legs / Jeans */}
        <g>
          {/* Left Leg */}
          <path d="M174 340L172 430H192L194 340Z" fill="#1E293B" />
          {/* Right Leg */}
          <path d="M206 340L208 430H228L226 340Z" fill="#1E293B" />

          {/* Shoes (Modern Sneakers) */}
          <path d="M164 426C164 426 172 422 186 422C195 422 195 434 195 434H164V426Z" fill="#1D68F5" />
          <rect x="162" y="432" width="34" height="5" rx="2.5" fill="#FFFFFF" />

          <path d="M206 426C206 426 214 422 228 422C237 422 237 434 237 434H206V426Z" fill="#1D68F5" />
          <rect x="204" y="432" width="34" height="5" rx="2.5" fill="#FFFFFF" />
        </g>

        {/* Body / Blue Shirt */}
        <g>
          <path d="M165 210C165 190 235 190 235 210L240 345H160L165 210Z" fill="#1D68F5" />
          {/* Backpack Straps */}
          <rect x="168" y="215" width="12" height="70" rx="6" fill="#0F172A" />
          <rect x="220" y="215" width="12" height="70" rx="6" fill="#0F172A" />
          {/* T-Shirt Neck Cutout */}
          <path d="M190 190C190 200 210 200 210 190" fill="#FED7AA" />
        </g>

        {/* Head and Neck */}
        <g>
          {/* Neck */}
          <rect x="194" y="176" width="14" height="18" rx="4" fill="#FDBA74" />
          {/* Face */}
          <ellipse cx="201" cy="155" rx="20" ry="24" fill="#FED7AA" />
          {/* Ears */}
          <circle cx="180" cy="157" r="4.5" fill="#FED7AA" />
          <circle cx="222" cy="157" r="4.5" fill="#FED7AA" />
          {/* Eyes & Smile */}
          <circle cx="194" cy="154" r="2" fill="#0F172A" />
          <circle cx="210" cy="154" r="2" fill="#0F172A" />
          <path d="M197 165C200 168 205 168 208 165" stroke="#C2410C" strokeWidth="2" strokeLinecap="round" />
          {/* Hair */}
          <path d="M180 150C178 132 190 126 201 126C215 126 224 133 223 150C223 154 219 146 215 145C210 143 205 148 200 145C194 142 190 146 185 147C182 147 180 149 180 150Z" fill="#1E293B" />
        </g>

        {/* Student Holding Tablet / Digital Notebook in Hands */}
        <g>
          {/* Left Arm and Hand */}
          <path d="M165 220C155 240 165 270 190 272" stroke="#1D68F5" strokeWidth="13" strokeLinecap="round" />
          {/* Right Arm and Hand */}
          <path d="M235 220C245 240 235 270 210 272" stroke="#1D68F5" strokeWidth="13" strokeLinecap="round" />
          
          {/* Tablet Device */}
          <rect x="180" y="240" width="56" height="42" rx="6" fill="#0F172A" transform="rotate(-5 180 240)" />
          <rect x="183" y="243" width="50" height="36" rx="4" fill="#38BDF8" transform="rotate(-5 180 240)" />
          {/* Glowing UI lines on screen */}
          <rect x="187" y="248" width="22" height="3" rx="1.5" fill="#FFFFFF" transform="rotate(-5 180 240)" />
          <rect x="187" y="254" width="34" height="2" rx="1" fill="#E0F2FE" transform="rotate(-5 180 240)" />
          <rect x="187" y="259" width="28" height="2" rx="1" fill="#E0F2FE" transform="rotate(-5 180 240)" />

          {/* Hands holding the tablet */}
          <circle cx="178" cy="265" r="7" fill="#FED7AA" />
          <circle cx="236" cy="260" r="7" fill="#FED7AA" />
        </g>
      </svg>
    </div>
  );
}
