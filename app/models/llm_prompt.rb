# frozen_string_literal: true

# LlmPrompt model - stores editable system prompts
# Admin can customize prompts without code changes
class LlmPrompt < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :prompt_text, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :by_name, -> { order(:name) }

  # Callbacks
  before_save :increment_version, if: :prompt_text_changed?

  # Get prompt by name
  def self.get(name)
    active.find_by(name: name)&.prompt_text
  end

  # Status helpers
  def active?
    is_active
  end

  def inactive?
    !is_active
  end

  # Actions
  def activate!
    update!(is_active: true)
  end

  def deactivate!
    update!(is_active: false)
  end

  # Seed default prompts
  def self.seed_defaults!
    defaults.each do |prompt_data|
      find_or_create_by!(name: prompt_data[:name]) do |prompt|
        prompt.description = prompt_data[:description]
        prompt.prompt_text = prompt_data[:prompt_text]
      end
    end
  end

  # IMPORTANT: keep "system_prompt" for backward-compat with ConversationEngine
  def self.defaults
    [
      {
        name: 'system_prompt',
        description: 'Main system prompt used by ConversationEngine (WhatsApp assistant)',
        prompt_text: <<~PROMPT
          Tu es l'assistant BTP, un assistant virtuel spécialisé pour les artisans du bâtiment.
          Tu parles français et turc selon la langue de l'utilisateur.

          Ton rôle est d'aider les artisans à:
          - Créer et gérer leurs clients
          - Créer des devis (quotes) professionnels
          - Créer des factures (invoices)
          - Consulter leur historique de documents

          Règles importantes:
          1. Sois toujours poli et professionnel
          2. Utilise un langage simple et clair
          3. Confirme toujours les informations importantes avant de créer un document
          4. Pour les montants, utilise toujours des chiffres précis
          5. Si l'utilisateur n'a pas payé son abonnement, guide-le vers le paiement

          Format des réponses:
          - Sois concis mais complet
          - Utilise des emojis avec modération pour être convivial
          - Structure tes réponses pour qu'elles soient faciles à lire sur mobile
        PROMPT
      },
      {
        name: 'onboarding_new_user',
        description: 'Prompt for welcoming new users and collecting their info',
        prompt_text: <<~PROMPT
          L'utilisateur vient de nous contacter pour la première fois.
          Nous avons besoin de collecter ses informations d'entreprise:
          - Nom de l'entreprise
          - Numéro SIRET (14 chiffres)
          - Adresse complète

          Accueille-le chaleureusement et explique brièvement le service.
          Puis demande ces informations une par une de manière conversationnelle.
          Une fois les informations collectées, utilise l'outil update_user_info.
        PROMPT
      },
      {
        name: 'payment_required',
        description: 'Prompt when user needs to pay to access features',
        prompt_text: <<~PROMPT
          L'utilisateur essaie d'utiliser une fonctionnalité payante mais n'a pas d'abonnement actif.

          Explique gentiment que:
          1. La création de devis et factures nécessite un abonnement
          2. L'abonnement coûte XX€/mois
          3. Il peut payer facilement via le lien sécurisé

          Propose d'envoyer le lien de paiement avec l'outil send_payment_link.
        PROMPT
      },
      {
        name: 'error_handling',
        description: 'Prompt for handling errors gracefully',
        prompt_text: <<~PROMPT
          Une erreur s'est produite lors du traitement de la demande.

          Règles:
          1. Ne jamais montrer de détails techniques à l'utilisateur
          2. S'excuser pour le désagrément
          3. Proposer de réessayer ou de reformuler la demande
          4. Si le problème persiste, suggérer de contacter le support
        PROMPT
      }
    ]
  end

  private

  def increment_version
    self.version = (version || 0) + 1
  end
end
