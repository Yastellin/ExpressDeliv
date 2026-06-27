import { jest, describe, it, expect, beforeEach } from '@jest/globals';

// ── Mocks ────────────────────────────────────────────────
jest.unstable_mockModule('../../features/incidents/incidents.repository.js', () => ({
  createIncident:   jest.fn(),
  findById:         jest.fn(),
  findAll:          jest.fn(),
  resoudreIncident: jest.fn(),
}));

jest.unstable_mockModule('../../features/livraisons/livraisons.repository.js', () => ({
  findById:      jest.fn(),
  updateStatut:  jest.fn(),
}));

jest.unstable_mockModule('../../middlewares/auditLogger.js', () => ({
  createAuditLog: jest.fn().mockResolvedValue(null),
  AuditActions: {
    INCIDENT_DECLARED: 'INCIDENT_DECLARED',
    INCIDENT_RESOLVED: 'INCIDENT_RESOLVED',
  },
}));

jest.unstable_mockModule('../../config/firebase.js', () => ({
  FCMService: { sendMultiple: jest.fn().mockResolvedValue(null) },
}));

jest.unstable_mockModule('../../config/winston.js', () => ({
  createLogger: () => ({
    info:  jest.fn(),
    debug: jest.fn(),
    warn:  jest.fn(),
    error: jest.fn(),
  }),
}));

jest.unstable_mockModule('../../config/database.js', () => ({
  query: jest.fn().mockResolvedValue({ rows: [] }),
}));

// ── Imports dynamiques ───────────────────────────────────
const { createIncident, resoudreIncident } =
  await import('../../features/incidents/incidents.service.js');

const IncidentsRepo  = await import('../../features/incidents/incidents.repository.js');
const LivraisonsRepo = await import('../../features/livraisons/livraisons.repository.js');

// ── Données de test ──────────────────────────────────────
const mockLivraison = {
  id:          'livr-uuid-001',
  livreur_id:  'livr-user-001',
  client_id:   'client-uuid-001',
  statut:      'EN_COURS',
  tentatives:  1,
};

const mockIncident = {
  id:           'incid-uuid-001',
  livraison_id: 'livr-uuid-001',
  type:         'CLIENT_ABSENT',
  description:  'Le client n\'était pas présent à l\'adresse indiquée',
  resolu:       false,
  declare_at:   new Date(),
};

// ════════════════════════════════════════════════════════
// createIncident
// ════════════════════════════════════════════════════════
describe('IncidentsService.createIncident()', () => {
  beforeEach(() => jest.clearAllMocks());

  it('doit créer un incident si la livraison est EN_COURS', async () => {
    LivraisonsRepo.findById.mockResolvedValue(mockLivraison);
    IncidentsRepo.createIncident.mockResolvedValue(mockIncident);
    LivraisonsRepo.updateStatut.mockResolvedValue({ ...mockLivraison, statut: 'ECHOUEE' });

    const result = await createIncident('livr-user-001', {
      livraison_id: 'livr-uuid-001',
      type:         'CLIENT_ABSENT',
      description:  'Le client n\'était pas présent',
    });

    expect(result.id).toBe('incid-uuid-001');
    expect(result.type).toBe('CLIENT_ABSENT');
    expect(LivraisonsRepo.updateStatut)
      .toHaveBeenCalledWith('livr-uuid-001', 'ECHOUEE');
  });

  it('doit lever une erreur si la livraison n\'appartient pas au livreur', async () => {
    LivraisonsRepo.findById.mockResolvedValue(mockLivraison);

    await expect(
      createIncident('autre-livreur', {
        livraison_id: 'livr-uuid-001',
        type:         'CLIENT_ABSENT',
        description:  'Test',
      })
    ).rejects.toMatchObject({ statusCode: 403, code: 'FORBIDDEN' });
  });

  it('doit lever une erreur si la livraison n\'est pas EN_COURS', async () => {
    LivraisonsRepo.findById.mockResolvedValue({
      ...mockLivraison, statut: 'AFFECTEE',
    });

    await expect(
      createIncident('livr-user-001', {
        livraison_id: 'livr-uuid-001',
        type:         'CLIENT_ABSENT',
        description:  'Test',
      })
    ).rejects.toMatchObject({ statusCode: 400, code: 'INVALID_STATUS' });
  });

  it('doit lever une erreur si 3 tentatives sont déjà atteintes', async () => {
    LivraisonsRepo.findById.mockResolvedValue({
      ...mockLivraison, tentatives: 3,
    });

    await expect(
      createIncident('livr-user-001', {
        livraison_id: 'livr-uuid-001',
        type:         'PANNE_VEHICULE',
        description:  'Test max tentatives',
      })
    ).rejects.toMatchObject({ statusCode: 400, code: 'INVALID_STATUS' });
  });

  it('doit lever une erreur si la livraison est introuvable', async () => {
    LivraisonsRepo.findById.mockResolvedValue(null);

    await expect(
      createIncident('livr-user-001', {
        livraison_id: 'inexistant',
        type:         'AUTRE',
        description:  'Test',
      })
    ).rejects.toMatchObject({ statusCode: 404, code: 'NOT_FOUND' });
  });
});

// ════════════════════════════════════════════════════════
// resoudreIncident
// ════════════════════════════════════════════════════════
describe('IncidentsService.resoudreIncident()', () => {
  beforeEach(() => jest.clearAllMocks());

  it('doit résoudre un incident ouvert', async () => {
    IncidentsRepo.findById.mockResolvedValue(mockIncident);
    IncidentsRepo.resoudreIncident.mockResolvedValue({
      ...mockIncident, resolu: true,
    });

    const result = await resoudreIncident('incid-uuid-001', 'admin-uuid-001');
    expect(result.resolu).toBe(true);
  });

  it('doit lever une erreur si l\'incident est déjà résolu', async () => {
    IncidentsRepo.findById.mockResolvedValue({
      ...mockIncident, resolu: true,
    });

    await expect(
      resoudreIncident('incid-uuid-001', 'admin-uuid-001')
    ).rejects.toMatchObject({ statusCode: 400, code: 'VALIDATION_ERROR' });
  });

  it('doit lever une erreur si l\'incident est introuvable', async () => {
    IncidentsRepo.findById.mockResolvedValue(null);

    await expect(
      resoudreIncident('inexistant', 'admin-uuid-001')
    ).rejects.toMatchObject({ statusCode: 404, code: 'NOT_FOUND' });
  });
});