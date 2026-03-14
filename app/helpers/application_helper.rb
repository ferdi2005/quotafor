module ApplicationHelper
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
end
