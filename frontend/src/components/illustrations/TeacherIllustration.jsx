import React from 'react';

export default function TeacherIllustration({ className = '' }) {
  return (
    <div className={`teacher-illustration-wrapper ${className}`} style={{ width: '100%', maxWidth: '420px', margin: '0 auto' }}>
      <svg
        viewBox="0 0 400 480"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ width: '100%', height: 'auto', display: 'block' }}
      >
        <defs>
          <linearGradient id="teacherBgGlow" x1="200" y1="50" x2="200" y2="440" gradientUnits="userSpaceOnUse">
            <stop stopColor="#E2EEFF" stopOpacity="0.75" />
            <stop stopColor="#F8FAFC" stopOpacity="0.1" />
          </linearGradient>

          <filter id="boardShadow" x="-15%" y="-15%" width="130%" height="130%" filterUnits="userSpaceOnUse">
            <feDropShadow dx="0" dy="6" stdDeviation="10" floodColor="#1D68F5" floodOpacity="0.12" />
          </filter>
        </defs>

        {/* Backdrop Circular Glow */}
        <circle cx="200" cy="240" r="170" fill="url(#teacherBgGlow)" />
        <circle cx="200" cy="240" r="190" stroke="#DBEAFE" strokeWidth="1.5" strokeDasharray="6 6" />

        {/* Presentation Board / Analytics Chart in Background */}
        <g filter="url(#boardShadow)" transform="translate(190, 90)">
          {/* Whiteboard Stand & Panel */}
          <rect width="165" height="135" rx="16" fill="#FFFFFF" />
          <rect x="8" y="8" width="149" height="119" rx="10" fill="#F8FAFC" />
          
          {/* Header Bar */}
          <rect x="18" y="18" width="50" height="6" rx="3" fill="#1D68F5" />
          <circle cx="138" cy="21" r="3" fill="#94A3B8" />
          <circle cx="146" cy="21" r="3" fill="#94A3B8" />

          {/* Grid lines */}
          <line x1="18" y1="50" x2="145" y2="50" stroke="#E2E8F0" strokeWidth="1" strokeDasharray="3 3" />
          <line x1="18" y1="80" x2="145" y2="80" stroke="#E2E8F0" strokeWidth="1" strokeDasharray="3 3" />
          <line x1="18" y1="110" x2="145" y2="110" stroke="#E2E8F0" strokeWidth="1" strokeDasharray="3 3" />

          {/* Analytics Line Chart */}
          <path
            d="M20 98L45 82L70 90L95 62L120 70L145 42"
            stroke="#1D68F5"
            strokeWidth="3.5"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          {/* Area fill under curve */}
          <path
            d="M20 98L45 82L70 90L95 62L120 70L145 42V115H20Z"
            fill="#1D68F5"
            fillOpacity="0.08"
          />

          {/* Data Points */}
          <circle cx="45" cy="82" r="3" fill="#FFFFFF" stroke="#1D68F5" strokeWidth="2" />
          <circle cx="95" cy="62" r="3" fill="#FFFFFF" stroke="#1D68F5" strokeWidth="2" />
          <circle cx="145" cy="42" r="3" fill="#FFFFFF" stroke="#1D68F5" strokeWidth="2" />
        </g>

        {/* Ground Soft Shadow */}
        <ellipse cx="170" cy="445" rx="105" ry="12" fill="#E2E8F0" />

        {/* Teacher / Instructor Figure */}
        {/* Legs / Formal Trousers or Skirt */}
        <g>
          <path d="M140 345L138 430H156L158 345Z" fill="#1E293B" />
          <path d="M170 345L172 430H190L188 345Z" fill="#1E293B" />

          {/* Formal Shoes / Heels */}
          <path d="M130 428C130 428 140 426 156 426V434H130Z" fill="#0F172A" />
          <path d="M170 428C170 428 180 426 196 426V434H170Z" fill="#0F172A" />
        </g>

        {/* Body / Blazer & Inner Top */}
        <g>
          {/* Inner Blouse (White) */}
          <path d="M150 205L160 270L170 205Z" fill="#FFFFFF" />

          {/* Royal Blue Suit Blazer */}
          <path d="M130 215C130 195 190 195 190 215L194 350H126L130 215Z" fill="#1D68F5" />
          {/* Lapels */}
          <polygon points="144,208 152,275 136,230" fill="#1557D4" />
          <polygon points="176,208 168,275 184,230" fill="#1557D4" />
          {/* Button */}
          <circle cx="160" cy="285" r="2.5" fill="#E2E8F0" />
        </g>

        {/* Head & Face */}
        <g>
          {/* Neck */}
          <rect x="154" y="180" width="12" height="18" rx="4" fill="#FDBA74" />
          {/* Face */}
          <ellipse cx="160" cy="160" rx="18" ry="22" fill="#FED7AA" />
          {/* Ears */}
          <circle cx="141" cy="161" r="3.5" fill="#FED7AA" />
          <circle cx="179" cy="161" r="3.5" fill="#FED7AA" />

          {/* Glasses */}
          <rect x="146" y="154" width="11" height="8" rx="2" stroke="#1E293B" strokeWidth="1.8" fill="none" />
          <rect x="163" y="154" width="11" height="8" rx="2" stroke="#1E293B" strokeWidth="1.8" fill="none" />
          <line x1="157" y1="158" x2="163" y2="158" stroke="#1E293B" strokeWidth="1.8" />

          {/* Eyes & Warm Smile */}
          <circle cx="151.5" cy="158" r="1.5" fill="#1E293B" />
          <circle cx="168.5" cy="158" r="1.5" fill="#1E293B" />
          <path d="M156 169C158 172 162 172 164 169" stroke="#C2410C" strokeWidth="1.8" strokeLinecap="round" />

          {/* Hair (Professional styling with bangs and shoulder length) */}
          <path d="M141 158C139 140 148 130 160 130C172 130 181 140 179 158C182 174 182 188 178 196C174 190 176 175 174 165C170 152 165 150 160 150C155 150 150 152 146 165C144 175 146 190 142 196C138 188 138 174 141 158Z" fill="#1E293B" />
        </g>

        {/* Arms Holding Clipboard / Digital Tablet */}
        <g>
          {/* Arms */}
          <path d="M130 225C122 245 130 275 152 280" stroke="#1D68F5" strokeWidth="12" strokeLinecap="round" />
          <path d="M190 225C198 245 188 275 168 280" stroke="#1D68F5" strokeWidth="12" strokeLinecap="round" />

          {/* Dark Professional Tablet / Binder */}
          <rect x="145" y="245" width="44" height="56" rx="5" fill="#0F172A" />
          <rect x="148" y="248" width="38" height="50" rx="3" fill="#1E293B" />
          {/* Clip top */}
          <rect x="157" y="242" width="20" height="6" rx="2" fill="#94A3B8" />

          {/* Papers / Screen */}
          <rect x="151" y="254" width="32" height="40" rx="2" fill="#FFFFFF" />
          <line x1="155" y1="262" x2="177" y2="262" stroke="#CBD5E1" strokeWidth="2" strokeLinecap="round" />
          <line x1="155" y1="268" x2="173" y2="268" stroke="#CBD5E1" strokeWidth="2" strokeLinecap="round" />
          <line x1="155" y1="274" x2="179" y2="274" stroke="#1D68F5" strokeWidth="2" strokeLinecap="round" />
          <line x1="155" y1="280" x2="170" y2="280" stroke="#CBD5E1" strokeWidth="2" strokeLinecap="round" />

          {/* Hands */}
          <circle cx="144" cy="272" r="6" fill="#FED7AA" />
          <circle cx="188" cy="272" r="6" fill="#FED7AA" />
        </g>
      </svg>
    </div>
  );
}
