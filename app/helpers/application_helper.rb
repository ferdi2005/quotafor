module ApplicationHelper
  def privacy_mode_enabled?
    return Current.privacy_mode unless Current.privacy_mode.nil?

    ActiveModel::Type::Boolean.new.cast(ENV.fetch("PRIVACY", false))
  end

  # Traduce il valore di un enum in italiano
  # es: enum_t(appointment, :appointment_type) => "Primo incontro"
  def enum_t(record, field)
    value = record.public_send(field)
    return "" if value.nil?

    model = record.class.name.underscore
    I18n.t("enums.#{model}.#{field}.#{value}", default: value.to_s.humanize)
  end

  # Genera le options tradotte per un enum (uso in select)
  # es: enum_options(Appointment, :appointment_type)
  def enum_options(klass, field)
    plural_field = "#{field}s"
    method = klass.respond_to?(plural_field) ? plural_field : field.to_s.pluralize
    model = klass.name.underscore
    klass.public_send(method).keys.map do |key|
      label = I18n.t("enums.#{model}.#{field}.#{key}", default: key.humanize)
      [ label, key ]
    end
  end

  def contact_call_badge_class(call_type)
    {
      "first_visit" => "bg-success",
      "second_visit" => "bg-warning text-dark",
      "assistance" => "bg-primary"
    }.fetch(call_type.to_s, "bg-secondary")
  end

  def satisfaction_level_options(selected = nil)
    options_for_select((1..10).to_a, selected)
  end
end
