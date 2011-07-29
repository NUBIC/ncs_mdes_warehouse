require 'rgl/adjacency'
require 'rgl/topsort'
require 'rgl/dot'
require 'rgl/connected_components'

##
# INCOMPLETE
#
# This was part of an attempt to use table metadata to dynamically
# reorder the MDES data streaming out of the NORC XML. It turned out
# that this was fundamentally impossible because the MDES includes a
# circular ref (Person -> Address -> Person). Reordering will have to
# be done at the record level.
class ReorderingInstanceSaver
  attr_reader :current_model
  attr_reader :input_order

  def initialize(input_order)
    @input_order = input_order

    $stderr.puts("    %33s %-33s" % %w(MDES Insertion))
    0.upto(input_order.size - 1).each do |i|
      $stderr.puts("%3d %33s %-33s" % [
          i,
          input_order[i].mdes_table_name,
          insertion_order[i].mdes_table_name
        ])
    end
  end

  def insertion_order
    @insertion_order ||=
      begin
        graph = RGL::DirectedAdjacencyGraph.new
        input_order.each { |model| graph.add_vertex(model) }

        input_order.each do |model|
          model.relationships.
            collect { |r| r.parent_model }.
            reject { |parent| parent == model }.
            each { |parent| graph.add_edge(parent, model) }
        end

        unless graph.acyclic?
          connections = graph.strongly_connected_components.comp_map.
            inject(Hash.new) { |h, (v, comp_n)|
              h[comp_n] ||= []
              h[comp_n] << v
              h
            }
          bad_sccs = connections.collect do |n, vs|
            if vs.size > 1
              "- SCC #{n}: #{vs.collect { |v| v.to_s.demodulize }.join(' ')}\n"
            end
          end.compact
          fail "Could not determine insertion order due to one or more cycles:\n#{bad_sccs.join("\n")}"
        end

        graph.topsort_iterator.to_a
      end
  end

  def current_model=(model)
    save_deferred_for(@current_model) if @current_model
    @current_model = model
  end

  ##
  # Returns the model after which `for_model` must be saved. This
  # should be the latest model in the input order on which `for_model`
  # depends according to insertion_order.
  def trigger_model(for_model)
  end

  ##
  # @return [Boolean]
  def save(instance)
    if t = trigger_model(instance.class)
      deferred_instances[t] ||= []
      deferred_instances[t] << for_model
      false
    else
      instance.save
      true
    end
  end

  ##
  # Instances that have been registered to save, but which need to be
  # deferred until after the specified model has been loaded.
  #
  # @return [Hash<Class, Array<Object>>] model after which this
  #   instance can be inserted => instances
  def deferred_instances
    @deferred_instances ||= {}
  end

  def save_deferred_for(model)
    if to_save = deferred_instances[model]
      to_save.each { |i| i.save }
      deferred_instances.delete(model)
    end
  end

  def verify_all_saved
    unless deferred_instances.empty?
      fail "There are #{deferred_instances.values.flatten.size} instances from #{deferred_instances.keys} whose saves were not triggered"
    end
  end
end
