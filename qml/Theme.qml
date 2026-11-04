pragma Singleton
import QtQuick

QtObject {
    id: theme

    // ── Active Theme State (Persisted) ────────────────────────────────────────
    property bool isDark: true

    function toggleTheme() {
        isDark = !isDark
    }

    // ── Surfaces & Canvases ───────────────────────────────────────────────────
    readonly property color bgCanvas:         isDark ? "#0B0F17" : "#F4F6F9"
    readonly property color surfaceNav:       isDark ? "#121824" : "#FFFFFF"
    readonly property color surfaceSidebar:   isDark ? "#0E1420" : "#F8FAFC"
    readonly property color surfaceCard:      isDark ? "#161F30" : "#FFFFFF"
    readonly property color surfaceCardHover: isDark ? "#1C273C" : "#F1F5F9"
    readonly property color surfaceInput:     isDark ? "#0D1117" : "#FFFFFF"
    readonly property color surfaceBadge:     isDark ? "#1F2937" : "#E2E8F0"

    // ── Borders ───────────────────────────────────────────────────────────────
    readonly property color borderDefault:    isDark ? "#222D3D" : "#E2E8F0"
    readonly property color borderSubtle:     isDark ? "#1A2230" : "#CBD5E1"
    readonly property color borderFocus:      isDark ? "#58A6FF" : "#2563EB"

    // ── Text Hierarchy ────────────────────────────────────────────────────────
    readonly property color textPrimary:      isDark ? "#F0F6FC" : "#0F172A"
    readonly property color textSecondary:    isDark ? "#8B949E" : "#475569"
    readonly property color textMuted:        isDark ? "#525E6F" : "#94A3B8"

    // ── Semantic Accents: Blue (Default / Active) ─────────────────────────────
    readonly property color accentBlue:       isDark ? "#58A6FF" : "#2563EB"
    readonly property color accentBlueBg:     isDark ? "#0D1D30" : "#EFF6FF"
    readonly property color accentBlueBorder: isDark ? "#1F6FEB" : "#93C5FD"

    // ── Semantic Accents: Green (Completed / Success) ─────────────────────────
    readonly property color accentGreen:      isDark ? "#3FB950" : "#16A34A"
    readonly property color accentGreenBg:    isDark ? "#0F2818" : "#F0FDF4"
    readonly property color accentGreenBorder:isDark ? "#238636" : "#86EFAC"

    // ── Semantic Accents: Amber (Learning / In-Progress) ──────────────────────
    readonly property color accentAmber:      isDark ? "#D29922" : "#D97706"
    readonly property color accentAmberBg:    isDark ? "#271E06" : "#FFFBEB"
    readonly property color accentAmberBorder:isDark ? "#9E6A03" : "#FDE68A"

    // ── Semantic Accents: Purple (Time / Metrics) ─────────────────────────────
    readonly property color accentPurple:     isDark ? "#A371F7" : "#7C3AED"
    readonly property color accentPurpleBg:   isDark ? "#211533" : "#FAF5FF"
    readonly property color accentPurpleBorder:isDark ?"#8957E5" : "#DDD6FE"

    // ── Semantic Accents: Red (Delete / Destructive) ──────────────────────────
    readonly property color accentRed:        isDark ? "#F85149" : "#DC2626"
    readonly property color accentRedBg:      isDark ? "#38171B" : "#FEF2F2"
    readonly property color accentRedBorder:  isDark ? "#DA3633" : "#FCA5A5"
}

