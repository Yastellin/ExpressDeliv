import Joi from 'joi';

// ── Règles de validation réutilisables ────────────────────
const rules = {
  nom:       Joi.string().min(2).max(100).pattern(/^[a-zA-ZÀ-ÿ\s\-']+$/),
  prenom:    Joi.string().min(2).max(100).pattern(/^[a-zA-ZÀ-ÿ\s\-']+$/),
  email:     Joi.string().email().lowercase().max(255),
  telephone: Joi.string().pattern(/^[0-9+\s\-]{8,20}$/),
  password:  Joi.string().min(8).max(128)
               .pattern(/^(?=.*[0-9])/)
               .messages({
                 'string.pattern.base': 'Le mot de passe doit contenir au moins 1 chiffre',
                 'string.min':          'Le mot de passe doit contenir au moins 8 caractères',
               }),
};

// ── Schéma : inscription ──────────────────────────────────
export const registerSchema = Joi.object({
  nom:       rules.nom.required().messages({
    'string.pattern.base': 'Le nom ne doit contenir que des lettres',
    'any.required':        'Le nom est requis',
  }),
  prenom:    rules.prenom.required().messages({
    'string.pattern.base': 'Le prénom ne doit contenir que des lettres',
    'any.required':        'Le prénom est requis',
  }),
  email:     rules.email.required().messages({
    'string.email':  'Format email invalide',
    'any.required':  "L'email est requis",
  }),
  telephone: rules.telephone.required().messages({
    'string.pattern.base': 'Numéro de téléphone invalide (minimum 8 chiffres)',
    'any.required':        'Le téléphone est requis',
  }),
  password:  rules.password.required(),
  adresse_defaut: Joi.string().max(500).optional(),
});

// ── Schéma : connexion ────────────────────────────────────
export const loginSchema = Joi.object({
  email:    rules.email.required().messages({
    'any.required': "L'email est requis",
  }),
  password: Joi.string().required().messages({
    'any.required': 'Le mot de passe est requis',
  }),
});

// ── Schéma : refresh token ────────────────────────────────
export const refreshSchema = Joi.object({
  refreshToken: Joi.string().required().messages({
    'any.required': 'Le refresh token est requis',
  }),
});

// ── Middleware de validation générique ────────────────────
// Usage : router.post('/register', validate(registerSchema), controller)
// Passe l'erreur Joi à errorHandler via next(err)
export const validate = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.body, {
    abortEarly:   false,   // retourne TOUTES les erreurs, pas juste la première
    stripUnknown: true,    // supprime les champs non définis dans le schéma
  });

  if (error) return next(error);

  // Remplace req.body par la valeur validée et nettoyée
  req.body = value;
  next();
};