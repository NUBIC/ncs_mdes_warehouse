require 'spec_helper'

shared_context :warehouse_record_creation_helpers do
  def save_wh(record)
    unless record.save
      messages = record.errors.keys.collect { |prop|
        record.errors[prop].collect { |e|
          v = record.send(prop)
          "#{e} (#{prop}=#{v.inspect})."
        }
      }.flatten
      fail "Could not save #{record} due to validation failures: #{messages.join(', ')}"
    end
    record
  end

  def create_warehouse_record_with_defaults(mdes_model, attributes={})
    mdes_model = case mdes_model
                 when String, Symbol
                   mdes_model(mdes_model)
                 else
                   mdes_model
                 end

    all_attrs = all_missing_attributes(mdes_model).
      merge(attributes)

    save_wh(mdes_model.new(all_attrs))
  end

  def all_missing_attributes(model)
    model.properties.
      select { |p| p.required? }.
      inject({}) { |h, prop| h[prop.name] = missing_value_for_property(prop); h }.
      merge(:psu_id => '20000030')
  end

  def missing_value_for_property(dm_prop)
    if dm_prop.options[:set]
      '-4'
    elsif dm_prop.class < ::DataMapper::Property::Numeric
      0
    else
      'NA'
    end
  end
end
