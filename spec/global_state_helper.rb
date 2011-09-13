module NcsNavigator::Warehouse::Spec
  class GlobalStatePreserver
    PRESERVED_WH_ATTRIBUTES = [
      :@env,
      :@bcdatabase,
      :@mdes,
      :@models_module
    ]

    PRESERVED_ENV_VARIABLES = %w(
      NCS_NAVIGATOR_ENV
    )

    def save
      store_wh_attributes
      store_env_variables
      store_dm_models

      self
    end

    def restore
      restore_dm_models
      restore_env_variables
      restore_wh_attributes

      self
    end

    def clear
      clear_wh_attributes
      clear_env_variables
      clear_dm_models

      self
    end

    private

    def store_wh_attributes
      @stored_wh_attributes = PRESERVED_WH_ATTRIBUTES.inject({}) do |attrs, k|
        attrs.merge!(k =>  NcsNavigator::Warehouse.instance_eval { instance_variable_get k })
      end
    end

    def restore_wh_attributes
      return unless @stored_wh_attributes
      @stored_wh_attributes.each do |k, v|
        NcsNavigator::Warehouse.instance_eval { instance_variable_set k, v }
      end
    end

    def clear_wh_attributes
      PRESERVED_WH_ATTRIBUTES.each do |k|
        NcsNavigator::Warehouse.instance_eval { instance_variable_set k, nil }
      end
    end

    def store_env_variables
      @stored_env_variables = PRESERVED_ENV_VARIABLES.inject({}) do |vars, k|
        vars.merge!(k => ENV[k])
      end
    end

    def restore_env_variables
      return unless @stored_env_variables
      @stored_env_variables.keys.each do |k|
        ENV[k] = @stored_env_variables[k]
      end
    end

    def clear_env_variables
      PRESERVED_ENV_VARIABLES.each { |k| ENV[k] = nil }
    end

    def store_dm_models
      @dm_models = DataMapper::Model.descendants.dup
    end

    def restore_dm_models
      return unless @dm_models
      clear_dm_models
      @dm_models.each do |model|
        DataMapper::Model.descendants << model
      end
    end

    def clear_dm_models
      DataMapper::Model.descendants.clear
    end
  end
end
