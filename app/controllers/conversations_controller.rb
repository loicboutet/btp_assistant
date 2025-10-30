class ConversationsController < ApplicationController
  layout 'client'
  
  def index
    @conversations = [
      OpenStruct.new(
        id: 1,
        client_name: 'Jean Martin',
        client_phone: '+33 6 12 34 56 78',
        last_message: 'Merci pour le devis, je le regarde.',
        last_message_at: 2.hours.ago,
        unread_count: 2,
        status: 'active'
      ),
      OpenStruct.new(
        id: 2,
        client_name: 'Marie Dubois',
        client_phone: '+33 6 98 76 54 32',
        last_message: 'Quand pouvez-vous commencer les travaux?',
        last_message_at: 5.hours.ago,
        unread_count: 0,
        status: 'active'
      ),
      OpenStruct.new(
        id: 3,
        client_name: 'Pierre Petit',
        client_phone: '+33 6 11 22 33 44',
        last_message: 'Parfait, je valide le devis.',
        last_message_at: 1.day.ago,
        unread_count: 1,
        status: 'active'
      ),
      OpenStruct.new(
        id: 4,
        client_name: 'Sophie Bernard',
        client_phone: '+33 6 44 33 22 11',
        last_message: 'Le paiement a été effectué.',
        last_message_at: 2.days.ago,
        unread_count: 0,
        status: 'archived'
      ),
      OpenStruct.new(
        id: 5,
        client_name: 'Luc Moreau',
        client_phone: '+33 6 55 66 77 88',
        last_message: 'Pouvez-vous m\'envoyer un nouveau devis?',
        last_message_at: 3.days.ago,
        unread_count: 3,
        status: 'active'
      )
    ]
  end

  def show
    @conversation = OpenStruct.new(
      id: params[:id],
      client_name: 'Jean Martin',
      client_phone: '+33 6 12 34 56 78',
      status: 'active',
      messages: [
        OpenStruct.new(id: 1, content: 'Bonjour, j\'ai besoin d\'un devis pour des travaux.', direction: 'incoming', created_at: 2.days.ago),
        OpenStruct.new(id: 2, content: 'Bonjour Jean, bien sûr! Pouvez-vous me donner plus de détails?', direction: 'outgoing', created_at: 2.days.ago),
        OpenStruct.new(id: 3, content: 'Je voudrais refaire l\'électricité de mon appartement.', direction: 'incoming', created_at: 2.days.ago),
        OpenStruct.new(id: 4, content: 'Je vous envoie un devis dans la journée.', direction: 'outgoing', created_at: 1.day.ago),
        OpenStruct.new(id: 5, content: 'Merci pour le devis, je le regarde.', direction: 'incoming', created_at: 2.hours.ago)
      ]
    )
  end
end
