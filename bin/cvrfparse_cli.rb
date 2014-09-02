#!/usr/bin/env ruby
require 'thor'
require 'cvrfparse'
require 'json'
require 'mongo'

class CvrfParseCLI < Thor
  include Thor::Actions

  def self.source_root
    File.dirname(__FILE__)
  end

  desc 'cvrf [DOCUMENT]', 'extract CVRF info for document'
  method_option :show_namespace, type: :boolean, default: false
  method_option :all, type: :boolean, default: false
  method_option :DocumentTitle, type: :boolean, default: false
  method_option :DocumentType, type: :boolean, default: false
  method_option :DocumentPublisher, type: :boolean, default: false
  method_option :DocumentTracking, type: :boolean, default: false
  method_option :DocumentNotes, type: :boolean, default: false
  method_option :DocumentDistribution, type: :boolean, default: false
  method_option :AggregateSeverity, type: :boolean, default: false
  method_option :DocumentReferences, type: :boolean, default: false
  method_option :Acknowledgments, type: :boolean, default: false
  def cvrf(document)
    namespace = :cvrf

    parsables = %w(DocumentTitle DocumentType DocumentPublisher DocumentTracking DocumentNotes DocumentDistribution AggregateSeverity DocumentReferences Acknowledgments)
    parsables.select! { |p| options[p.to_sym] } unless options[:all]

    nodes = parse(document, parsables, namespace)
    print_nodes(nodes, options[:show_namespace])
  end

  desc 'vuln [DOCUMENT]', 'extract Vulnerability info for document'
  method_option :all, type: :boolean, default: false
  method_option :show_namespace, type: :boolean, default: false
  method_option :Title, type: :boolean, default: false
  method_option :ID, type: :boolean, default: false
  method_option :Notes, type: :boolean, default: false
  method_option :DiscoveryDate, type: :boolean, default: false
  method_option :ReleaseDate, type: :boolean, default: false
  method_option :Involvements, type: :boolean, default: false
  method_option :CVE, type: :boolean, default: false
  method_option :CWE, type: :boolean, default: false
  method_option :ProductStatuses, type: :boolean, default: false
  method_option :Threats, type: :boolean, default: false
  method_option :CVSSScoreSets, type: :boolean, default: false
  method_option :Remediations, type: :boolean, default: false
  method_option :References, type: :boolean, default: false
  method_option :Acknowledgments, type: :boolean, default: false
  def vuln(document)
    namespace = :vuln

    parsables = %w(Title ID Notes DiscoveryDate ReleaseDate Involvements CVE CWE ProductStatuses Threats CVSSScoreSets Remediations References Acknowledgments)
    parsables.select! { |p| options[p.to_sym] } unless options[:all]

    nodes = parse(document, parsables, namespace)
    print_nodes(nodes, options[:show_namespace])
  end

  desc 'prod [DOCUMENT]', 'extract Product info for document'
  method_option :all, type: :boolean, default: false
  method_option :show_namespace, type: :boolean, default: false
  method_option :Branch, type: :boolean, default: false
  method_option :FullProductName, type: :boolean, default: false
  method_option :Relationship, type: :boolean, default: false
  method_option :ProductGroups, type: :boolean, default: false
  def prod(document)
    namespace = :prod

    parsables = %w(Branch FullProductName Relationship ProductGroups)
    parsables.select! { |p| options[p.to_sym] } unless options[:all]

    nodes = parse(document, parsables, namespace)
    print_nodes(nodes, options[:show_namespace])
  end

  desc 'validate [DOCUMENT]', 'validate a CVRF document'
  method_option :schema, type: :string
  def validate(document)
    parser = CVRFPARSE::CvrfParser.new
    schema = options[:schema]

    result = (schema.nil?) ? parser.validate(document) : parser.validate(document, schema)

    if result.empty?
      say 'Valid', :green
    else
      say 'Invalid', :red
      result.each { |error| say error }
    end
  end

  desc 'to_mongo [DOCUMENT]', 'insert info from CVRF document to mongodb database'
  method_option :host, type: :string, default: 'localhost'
  method_option :port, type: :numeric, default: 27_017
  method_option :database, type: :string, default: 'cvrf'
  method_option :username, type: :string
  method_option :password, type: :string
  def to_mongo(document)
    # DocumentTitle must be unique on mongo collection, for avoid duplicates
    # db.cvrfdocs.ensureIndex( { "DocumentTitle" : 1 }, { unique: true } )
    
    mongo_client = Mongo::MongoClient.new(options[:host], options[:port])
    db = mongo_client.db(options[:database])

    if options.key?(:username) && options.key?(:password)
      db.authenticate(options[:username], options[:password])
    end

    collection = db['cvrfdocs']

    nodes = parse(document, ['cvrfdoc'], :cvrf)
    cvrfdoc = nodes_to_bson(nodes[0].children)

    begin
      collection.insert(cvrfdoc)
      say "#{document} inserted on mongo database", :green
    rescue Mongo::OperationFailure => e
      say e.message, :red
    end
  end

  no_tasks do
    def nodes_to_bson(nodes)
      result = {}
      nodes.each do |node|
        length = node.children.length
        if length > 1
          result[node.name] = nodes_to_bson(node.children)
        else
          unless node.content.strip.empty?
            result[node.name] = node.content.strip
          end
        end
      end
      result
    end

    def parse(document, parsables, namespace)
      parser = CVRFPARSE::CvrfParser.new

      parser.parse(document, parsables, namespace)
    end

    def print_nodes(nodes, show_namespace, level = 0)
      nodes.each { |node| print_one_node(node, show_namespace, level + 1) }
    end

    def print_one_node(node, show_namespace, level = 0)
      length = node.children.length
      if length > 1
        say "#{"\t" * level}[#{node.name.strip}]"
        print_nodes(node.children, show_namespace, level + 1)
      else
        if show_namespace
          say "#{"\t" * level}[#{node.namespace.href.strip} #{node.name.strip}] #{node.text.strip}" unless node.content.strip.empty?
        else
          say "#{"\t" * level}[#{node.name.strip}] #{node.content.strip}" unless node.content.strip.empty?
        end
      end
    end
  end
end

CvrfParseCLI.start(ARGV)
