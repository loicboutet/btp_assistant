# frozen_string_literal: true

# Tool: Create a new client
# Used when creating quotes/invoices for clients that don't exist yet
#
module LlmTools
  class CreateClient < BaseTool
    def execute(name:, address: nil, siret: nil, contact_phone: nil, contact_email: nil)
      # Clean inputs first
      name = name&.strip
      address = address&.strip
      siret = siret&.gsub(/\s/, '')
      contact_phone = contact_phone&.strip
      contact_email = contact_email&.strip&.downcase

      # Validate required fields
      return error("Le nom du client est obligatoire", field: "name") if name.blank?

      # Validate optional fields
      if siret.present?
        siret_error = validate_siret(siret)
        return siret_error if siret_error
      end

      if contact_email.present?
        email_error = validate_email(contact_email)
        return email_error if email_error
      end

      # Check for duplicate
      existing = user.clients.find_by("LOWER(name) = ?", name.downcase)
      if existing
        return error("Un client nommé '#{existing.name}' existe déjà (ID: #{existing.id})", field: "name")
      end

      # Create the client
      client = user.clients.build(
        name: name,
        address: address,
        siret: siret,
        contact_phone: contact_phone,
        contact_email: contact_email,
        created_via: "whatsapp"
      )

      if client.save
        log_execution("client_created", client_id: client.id, client_name: client.name)
        
        success(
          client_id: client.id,
          name: client.name,
          address: client.address,
          siret: client.formatted_siret,
          contact_phone: client.contact_phone,
          contact_email: client.contact_email,
          message: "Client '#{client.name}' créé avec succès"
        )
      else
        error("Impossible de créer le client: #{client.errors.full_messages.join(', ')}")
      end
    end
  end
end
