module ActiveRecordParser
  def parse_active_record(the_class)
    active_record_matchers = {}
    active_record_matchers[:relations] = parse_relations(the_class.reflect_on_all_associations)
    active_record_matchers[:nested_attributes] = the_class.nested_attributes_options
    active_record_matchers[:enums] = the_class.defined_enums
    active_record_matchers[:db_columns] = the_class.columns.map(&:name).drop(3)
    active_record_matchers[:db_indexes] = parse_db_indexes(the_class)
    active_record_matchers[:implicit_order_columns] = [the_class.implicit_order_column].flatten
    active_record_matchers[:readonly_attributes] = the_class.readonly_attributes

    active_record_matchers
  end

  private

  def parse_relations(associations)
    relations = {
      belongs_to: [],
      has_many: [],
      has_one: [],
      has_and_belongs_to_many: []
    }
    associations.each do |association|
      case association.macro
      when :belongs_to
        relations[:belongs_to] << association.name
      when :has_many
        relations[:has_many] << association.name
      when :has_one
        relations[:has_one] << association.name
      when :has_and_belongs_to_many
        relations[:has_and_belongs_to_many] << association.name
      end
    end

    return nil if relations.values.all?(&:empty?)
    relations
  end

  def parse_serialized_attributes(the_class)
    serialized_attributes = []

    the_class.attribute_names.each do |attribute_name|
      column = the_class.column_for_attribute(attribute_name)
      serialized_attributes << attribute_name if column&.type == :text && column&.cast_type&.is_a?(ActiveRecord::Type::Serialized)
    end

    serialized_attributes
  end

  def parse_db_indexes(the_class)
    db_indexes = {}
    the_class.connection.indexes(the_class.table_name).map { { _1.unique => _1.columns.first } }.each do |index|
      key = index.keys.first
      next db_indexes[key] << index[key] if db_indexes[key]
      db_indexes[key] = [index[key]]
    end
    db_indexes
  end
end