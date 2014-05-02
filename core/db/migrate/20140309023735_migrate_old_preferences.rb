class MigrateOldPreferences < ActiveRecord::Migration
  def up
    migrate_preferences(Spree::Calculator)
    migrate_preferences(Spree::PaymentMethod)
    migrate_preferences(Spree::PromotionRule)
  end

  def down
  end

  private
  def migrate_preferences klass
    klass.reset_column_information
    begin
      klass.find_each do |record|
        store = Spree::Preferences::ScopedStore.new(record.class.name.underscore, record.id)
        record.defined_preferences.each do |key|
          value = store.fetch(key){}
          record.preferences[key] = value unless value.nil?
        end
        record.save!
      end
    end
    rescue
      # Spree::Calculator::PerItem has since been removed in 2.2.stable, rescue in silent to
      # ignore error: NameError: uninitialized constant Spree::Calculator::PerItem
    end      
  end
end
