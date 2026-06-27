import { jest, describe, it, expect, beforeEach } from '@jest/globals';

// ── Variables d'environnement pour les tests ──────────────
// JWT_SECRET doit être défini AVANT l'import du service
process.env.JWT_SECRET         = 'test_jwt_secret_for_jest_minimum_32_chars';
process.env.JWT_REFRESH_SECRET = 'test_refresh_secret_for_jest_different';
process.env.JWT_EXPIRES_IN     = '15m';
process.env.JWT_REFRESH_EXPIRES_IN = '7d';

// ── Mocks des dépendances ────────────────────────────────
jest.unstable_mockModule('../../features/auth/auth.repository.js', () => ({
  findUserByEmail:       jest.fn(),
  findUserById:          jest.fn(),
  createUser:            jest.fn(),
  saveRefreshToken:      jest.fn(),
  findValidRefreshToken: jest.fn(),
  revokeRefreshToken:    jest.fn(),
  revokeAllUserTokens:   jest.fn(),
}));

jest.unstable_mockModule('../../middlewares/auditLogger.js', () => ({
  createAuditLog: jest.fn().mockResolvedValue(null),
  AuditActions:   { LOGIN: 'AUTH_LOGIN', REGISTER: 'AUTH_REGISTER', LOGOUT: 'AUTH_LOGOUT' },
}));

jest.unstable_mockModule('../../config/winston.js', () => ({
  createLogger: () => ({
    info:  jest.fn(),
    debug: jest.fn(),
    warn:  jest.fn(),
    error: jest.fn(),
  }),
}));

// ── Import dynamique après mocks ─────────────────────────
const { register, login, logout } =
  await import('../../features/auth/auth.service.js');

const AuthRepository =
  await import('../../features/auth/auth.repository.js');

// ── Données de test ──────────────────────────────────────
const mockUser = {
  id:            'uuid-test-123',
  nom:           'Rakoto',
  prenom:        'Jean',
  email:         'jean@test.com',
  telephone:     '0340000000',
  password_hash: '$2a$12$hashedpassword',
  role_nom:      'CLIENT',
  statut:        'ACTIF',
  created_at:    new Date(),
};

// ════════════════════════════════════════════════════════
// REGISTER
// ════════════════════════════════════════════════════════
describe('AuthService.register()', () => {
  beforeEach(() => jest.clearAllMocks());

  it('doit créer un utilisateur et retourner les tokens', async () => {
    AuthRepository.findUserByEmail.mockResolvedValue(null);
    AuthRepository.createUser.mockResolvedValue(mockUser);
    AuthRepository.saveRefreshToken.mockResolvedValue(null);

    const result = await register({
      nom: 'Rakoto', prenom: 'Jean',
      email: 'jean@test.com', telephone: '0340000000',
      password: 'motdepasse1',
    });

    expect(result).toHaveProperty('accessToken');
    expect(result).toHaveProperty('refreshToken');
    expect(result.user.email).toBe('jean@test.com');
    expect(AuthRepository.createUser).toHaveBeenCalledTimes(1);
  });

  it("doit lever une erreur si l'email existe déjà", async () => {
    AuthRepository.findUserByEmail.mockResolvedValue(mockUser);

    await expect(register({
      nom: 'Rakoto', prenom: 'Jean',
      email: 'jean@test.com', telephone: '034',
      password: 'motdepasse1',
    })).rejects.toMatchObject({
      statusCode: 409,
      code:       'ALREADY_EXISTS',
    });

    expect(AuthRepository.createUser).not.toHaveBeenCalled();
  });
});

// ════════════════════════════════════════════════════════
// LOGIN
// ════════════════════════════════════════════════════════
describe('AuthService.login()', () => {
  beforeEach(() => jest.clearAllMocks());

  it('doit connecter un utilisateur avec les bons identifiants', async () => {
    const bcrypt = await import('bcryptjs');
    const hash   = await bcrypt.hash('motdepasse1', 4);
    AuthRepository.findUserByEmail.mockResolvedValue({ ...mockUser, password_hash: hash });
    AuthRepository.saveRefreshToken.mockResolvedValue(null);

    const result = await login('jean@test.com', 'motdepasse1');

    expect(result).toHaveProperty('accessToken');
    expect(result).toHaveProperty('refreshToken');
  });

  it("doit lever une erreur si l'email est inconnu", async () => {
    AuthRepository.findUserByEmail.mockResolvedValue(null);

    await expect(login('inconnu@test.com', 'motdepasse1'))
      .rejects.toMatchObject({ statusCode: 401, code: 'UNAUTHORIZED' });
  });

  it('doit lever une erreur si le mot de passe est incorrect', async () => {
    const bcrypt = await import('bcryptjs');
    const hash   = await bcrypt.hash('motdepasse1', 4);
    AuthRepository.findUserByEmail.mockResolvedValue({ ...mockUser, password_hash: hash });

    await expect(login('jean@test.com', 'mauvaismdp'))
      .rejects.toMatchObject({ statusCode: 401, code: 'UNAUTHORIZED' });
  });

  it('doit lever une erreur si le compte est suspendu', async () => {
    AuthRepository.findUserByEmail.mockResolvedValue({
      ...mockUser, statut: 'SUSPENDU',
    });

    await expect(login('jean@test.com', 'motdepasse1'))
      .rejects.toMatchObject({ statusCode: 403, code: 'FORBIDDEN' });
  });
});

// ════════════════════════════════════════════════════════
// LOGOUT
// ════════════════════════════════════════════════════════
describe('AuthService.logout()', () => {
  it('doit révoquer le refresh token', async () => {
    AuthRepository.revokeRefreshToken.mockResolvedValue(null);

    await expect(logout('token-abc', 'uuid-test-123'))
      .resolves.toBeUndefined();

    expect(AuthRepository.revokeRefreshToken)
      .toHaveBeenCalledWith('token-abc');
  });
});