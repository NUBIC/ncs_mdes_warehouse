require 'logger'

##
# Another attempt at deferring saves to get around circular
# dependencies. This one was also thwarted -- the NORC data actually
# had record-level circular dependencies, so the only solution was to
# defer the constraints.
#
# This remains because it will be the model for something to use to
# track references when loading NORC data in the future. (The problem
# with deferring the constraints is that we'll only get the first
# failure from the database, instead of all of them.)
class DeferredInstanceSaver
  attr_reader :deferred

  def initialize
    @deferred = []
    @log = Logger.new(File.open('deferred_saver.log', 'w'))
  end

  ##
  # @return [Hash<Class, Array<String>>]
  def saved
    @saved ||= {}
  end

  def saved_count
    @saved.values.inject(0) { |s, vs| s + vs.size }
  end

  def save_or_defer(i)
    deferrer = DeferredInstance.new(i, self, @log)
    if deferrer.ready?
      save(i)
      @log.info("Immediately saved #{deferrer.instance_s}. Currently #{deferred.size} deferred.")
      @log.info("Known PKs for this model are #{saved[deferrer.model.mdes_table_name].inspect}.")
      true
    else
      deferred << deferrer
      @log.info("Deferring #{deferrer.instance_s} due to #{deferrer.outstanding_dependencies.inspect}. Currently #{deferred.size} deferred.")
      false
    end
  end

  def verify_all_saved
    unless deferred.empty?
      fail "Deferred instances never resolved:\n- #{deferred.collect(&:to_s).join("\n- ")}"
    end
  end

  def save(i)
    i.save
    register_instance(i)
    save_any_ready
  end

  private

  def register_instance(i)
    saved[i.class.mdes_table_name] ||= []
    saved[i.class.mdes_table_name] << i.key.first # since nothing has a composite key
  end

  def save_any_ready
    deferred.dup.each do |deferrer|
      deferrer.save_if_ready
    end
  end

  class DeferredInstance
    attr_reader :instance

    def initialize(instance, saver, log)
      @instance = instance
      @saver = saver
      @log = log
    end

    def model
      @instance.class
    end

    def outstanding_dependencies
      model.relationships.select { |r| r.child_model == model }.collect { |r|
        fk = self.instance.send(r.child_key.collect(&:name).first)
        [r.parent_model.mdes_table_name, fk] if fk
      }.compact.reject { |parent, pk_value|
        (@saver.saved[parent] || []).include?(pk_value)
      }
    end

    def ready?
      outstanding_dependencies.empty?
    end

    def save_if_ready
      if ready?
        @log.info("Saving #{self}")
        @saver.deferred.delete(self)
        @saver.save(instance)
      end
    end

    def instance_s
      [instance.class.mdes_table_name, instance.key.first].compact.join(' ')
    end

    def to_s
      "deferred instance #{instance_s}"
    end
  end
end
