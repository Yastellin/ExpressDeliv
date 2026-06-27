import { jest, describe, it, expect, beforeEach } from '@jest/globals';

// ── Mocks ────────────────────────────────────────────────
jest.unstable_mockModule('../../features/livraisons/livraisons.repository.js', () => ({
  createLivraison: jest.fn(),
  findById:        jest.fn(),
  findAll:         jest.fn(),
  updateStatut:    jest.fn(),
  savePreuve:      jest.fn(),
  getPositions:    jest.fn(),
}));

jest.unstable_mockModule('../../features/commandes/commandes.repository.js', () => ({
  findById: jest.fn(),
}));

jest.unstable_mockModule('../../middlewares/auditLogger.js', () => ({
  createAuditLog: jest.fn().mockResolvedValue(null),
  AuditActions: {
    LIVRAISON_CREATED:   'LIVRAISON_CREATED',
    LIVRAISON_ACCEPTED:  'LIVRAISON_ACCEPTED',
    LIVRAISON_REFUSED:   'LIVRAISON_REFUSED',
    PREUVE_SUBMITTED:    'PREUVE_SUBMITTED',
  },
}));

jest.unstable_mockModule('../../config/firebase.js', () => ({
  FCMService: { sendMultiple: jest.fn().mockResolvedValue(null) },
}));

jest.unstable_mockModule('../../sockets/socket.init.js', () => ({
  getIO: () => ({ to: () => ({ emit: jest.fn() }) }),
}));

jest.unstable_mockModule('../../config/winston.js', () => ({
  createLogger: () => ({
    info: jest.fn(), debug: jest.fn(),
    warn: jest.fn(), error: jest.fn(),
  }),
}));

jest.unstable_mockModule('../../config/database.js', () => ({
  query: jest.fn().mockResolvedValue({ rows: [] }),
}));

// ── Imports dynamiques ───────────────────────────────────
const {
  createLivraison, accepterLivraison,
  refuserLivraison, soumettrePreuve, getLivraison,
} = await import('../../features/livraisons/livraisons.service.js');

const LivraisonsRepo = await import('../../features/livraisons/livraisons.repository.js');
const CommandesRepo  = await import('../../features/commandes/commandes.repository.js');

// ── Données de test ──────────────────────────────────────
const mockCommande = {
  id: 'cmd-uuid-001', statut: 'EN_ATTENTE',
  adresse_livraison: 'Analakely, Antananarivo',
};

const mockLivraison = {
  id:         'livr-uuid-001',
  commande_id: 'cmd-uuid-001',
  livreur_id:  'livr-user-001',
  client_id:   'client-uuid-001',
  statut:      'AFFECTEE',
  tentatives:  1,
  livreur_prenom: 'Paul',
};

// ════════════════════════════════════════════════════════
// createLivraison
// ════════════════════════════════════════════════════════
describe('LivraisonsService.createLivraison()', () => {
  beforeEach(() => jest.clearAllMocks());

  it('doit créer une livraison si la commande est EN_ATTENTE', async () => {
    CommandesRepo.findById.mockResolvedValue(mockCommande);
    LivraisonsRepo.createLivraison.mockResolvedValue(mockLivraison);

    const result = await createLivraison(
      'cmd-uuid-001', 'livr-user-001', 'admin-uuid-001'
    );

    expect(result.id).toBe('livr-uuid-001');
    expect(LivraisonsRepo.createLivraison).toHaveBeenCalledTimes(1);
  });

  it('doit lever une erreur si la commande est déjà LIVREE', async () => {
    CommandesRepo.findById.mockResolvedValue({ ...mockCommande, statut: 'LIVREE' });

    await expect(
      createLivraison('cmd-uuid-001', 'livr-user-001', 'admin-uuid-001')
    ).rejects.toMatchObject({ statusCode: 400, code: 'INVALID_STATUS' });
  });

  it('doit lever une erreur si la commande est introuvable', async () => {
    CommandesRepo.findById.mockResolvedValue(null);

    await expect(
      createLivraison('inexistant', 'livr-user-001', 'admin-uuid-001')
    ).rejects.toMatchObject({ statusCode: 404, code: 'NOT_FOUND' });
  });
});

// ════════════════════════════════════════════════════════
// accepterLivraison
// ════════════════════════════════════════════════════════
describe('LivraisonsService.accepterLivraison()', () => {
  beforeEach(() => jest.clearAllMocks());

  it('doit accepter la mission si le livreur est le bon', async () => {
    LivraisonsRepo.findById.mockResolvedValue(mockLivraison);
    LivraisonsRepo.updateStatut.mockResolvedValue({ ...mockLivraison, statut: 'EN_COURS' });

    const result = await accepterLivraison('livr-uuid-001', 'livr-user-001');
    expect(result.statut).toBe('EN_COURS');
  });

  it("doit lever une erreur si ce n'est pas la mission du livreur", async () => {
    LivraisonsRepo.findById.mockResolvedValue(mockLivraison);

    await expect(
      accepterLivraison('livr-uuid-001', 'autre-livreur')
    ).rejects.toMatchObject({ statusCode: 403, code: 'FORBIDDEN' });
  });

  it("doit lever une erreur si le statut n'est pas AFFECTEE", async () => {
    LivraisonsRepo.findById.mockResolvedValue({ ...mockLivraison, statut: 'EN_COURS' });

    await expect(
      accepterLivraison('livr-uuid-001', 'livr-user-001')
    ).rejects.toMatchObject({ statusCode: 400, code: 'INVALID_STATUS' });
  });
});

// ════════════════════════════════════════════════════════
// getLivraison — contrôle d'accès
// ════════════════════════════════════════════════════════
describe('LivraisonsService.getLivraison()', () => {
  beforeEach(() => jest.clearAllMocks());

  it("un CLIENT ne peut pas voir la livraison d'un autre", async () => {
    LivraisonsRepo.findById.mockResolvedValue(mockLivraison);

    await expect(
      getLivraison('livr-uuid-001', { id: 'autre-client', role: 'CLIENT' })
    ).rejects.toMatchObject({ statusCode: 403, code: 'FORBIDDEN' });
  });

  it("un ADMIN peut voir n'importe quelle livraison", async () => {
    LivraisonsRepo.findById.mockResolvedValue(mockLivraison);

    const result = await getLivraison(
      'livr-uuid-001', { id: 'admin-uuid-001', role: 'ADMIN' }
    );
    expect(result.id).toBe('livr-uuid-001');
  });
});