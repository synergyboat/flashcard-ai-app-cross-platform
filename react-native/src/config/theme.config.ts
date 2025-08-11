export const COLORS = {
  PRIMARY: '#0c7fff',
  SECONDARY: '#4dd0e1',
  
  BACKGROUND: {
    GRADIENT_START: '#FEF8FF',
    GRADIENT_END: '#F0E6FF',
    CARD: '#ffffff',
    HEADER: '#FEF8FF',
    MODAL: '#1b1d26',
    TRANSPARENT: 'rgba(255, 255, 255, 0)',
  },
  
  TEXT: {
    PRIMARY: '#333333',
    SECONDARY: '#666666',
    LIGHT: '#999999',
    WHITE: '#ffffff',
    ERROR: '#ff4444',
  },
  
  BORDER: {
    LIGHT: '#E0E0E0',
    MEDIUM: '#9E9E9E',
    DARK: '#333333',
  },
  
  SHADOW: {
    COLOR: '#000000',
    BLUE: '#4dd0e1',
  },
  
  STATUS: {
    SUCCESS: '#4CAF50',
    WARNING: '#FF9800',
    ERROR: '#f44336',
    INFO: '#2196F3',
  },
} as const;

export const TYPOGRAPHY = {
  SIZES: {
    TINY: 12,
    SMALL: 14,
    MEDIUM: 16,
    LARGE: 18,
    XLARGE: 20,
    XXLARGE: 24,
  },
  WEIGHTS: {
    NORMAL: 'normal' as const,
    MEDIUM: '600' as const,
    BOLD: 'bold' as const,
  },
  LINE_HEIGHTS: {
    TIGHT: 16,
    NORMAL: 20,
    LOOSE: 24,
  },
} as const;

export const SHADOWS = {
  CARD: {
    shadowColor: COLORS.SHADOW.COLOR,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 8,
  },
  FAB: {
    shadowColor: COLORS.SHADOW.BLUE,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.6,
    shadowRadius: 8,
    elevation: 8,
  },
  BUTTON: {
    shadowColor: COLORS.PRIMARY,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 16,
    elevation: 5,
  },
} as const;