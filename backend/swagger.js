import swaggerJsdoc from 'swagger-jsdoc';
import path         from 'path';
import { fileURLToPath } from 'url';

// Compatibilité __dirname avec ES Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname  = path.dirname(__filename);

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title:       'EXPRESSDELIV API',
      version:     '1.0.0',
      description: 'API REST du système de suivi de livraison express — L3 Génie Logiciel',
      contact: {
        name: 'EXPRESSDELIV',
      },
    },
    servers: [
      {
        url:         'http://localhost:3000/api/v1',
        description: 'Serveur de développement',
      },
    ],

    // ── Composants réutilisables ──────────────────────────
    components: {
      // Schéma d'authentification Bearer JWT
      securitySchemes: {
        bearerAuth: {
          type:         'http',
          scheme:       'bearer',
          bearerFormat: 'JWT',
        },
      },

      // Schémas de réponse communs
      schemas: {
        SuccessResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
            message: { type: 'string' },
            data:    { type: 'object' },
          },
        },
        ErrorResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            error: {
              type: 'object',
              properties: {
                code:    { type: 'string', example: 'NOT_FOUND' },
                message: { type: 'string' },
              },
            },
          },
        },
        PaginatedResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
            data:    { type: 'array', items: {} },
            pagination: {
              type: 'object',
              properties: {
                page:       { type: 'integer', example: 1 },
                limit:      { type: 'integer', example: 20 },
                total:      { type: 'integer' },
                totalPages: { type: 'integer' },
              },
            },
          },
        },
        Utilisateur: {
          type: 'object',
          properties: {
            id:        { type: 'string', format: 'uuid' },
            nom:       { type: 'string', example: 'Rakoto' },
            prenom:    { type: 'string', example: 'Jean' },
            email:     { type: 'string', format: 'email' },
            telephone: { type: 'string', example: '0340000000' },
            role:      { type: 'string', enum: ['CLIENT', 'LIVREUR', 'ADMIN', 'SUPER_ADMIN'] },
            statut:    { type: 'string', enum: ['ACTIF', 'INACTIF', 'SUSPENDU'] },
          },
        },
        Commande: {
          type: 'object',
          properties: {
            id:                    { type: 'string', format: 'uuid' },
            client_id:             { type: 'string', format: 'uuid' },
            statut:                { type: 'string', enum: ['EN_ATTENTE', 'CONFIRMEE', 'EN_COURS', 'LIVREE', 'ANNULEE'] },
            adresse_livraison:     { type: 'string' },
            montant_total:         { type: 'number', example: 25000 },
            created_at:            { type: 'string', format: 'date-time' },
          },
        },
        Livraison: {
          type: 'object',
          properties: {
            id:          { type: 'string', format: 'uuid' },
            commande_id: { type: 'string', format: 'uuid' },
            livreur_id:  { type: 'string', format: 'uuid' },
            statut:      { type: 'string', enum: ['AFFECTEE', 'EN_COURS', 'LIVREE', 'ECHOUEE', 'ANNULEE'] },
            tentatives:  { type: 'integer', example: 1 },
          },
        },
      },
    },

    // Sécurité globale : toutes les routes nécessitent Bearer JWT
    security: [{ bearerAuth: [] }],
  },

  // Fichiers à scanner pour les annotations @swagger
  apis: [
    path.join(__dirname, 'src/features/**/*.routes.js'),
  ],
};

const swaggerSpec = swaggerJsdoc(options);

export default swaggerSpec;