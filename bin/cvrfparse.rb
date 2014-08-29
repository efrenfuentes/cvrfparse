#!/usr/bin/env ruby
require 'thor'
require 'cvrfparse'
require 'json'

class CvrfParse < Thor
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

  desc 'validate [DOCUMENT]', 'validate an CVRF document'
  method_option :schema, type: :string
  def validate(document)
    parser = CVRFPARSE::CVRF_parser::new
    schema = options[:schema]

    result = (schema.nil?) ? parser.validate(document) : parser.validate(document, schema)

    if result.empty?
      say 'Valid', :green
    else
      say 'Invalid', :red
      result.each do |error|
        say error
      end
    end
  end

  no_tasks do
    def parse(document, parsables, namespace)
      parser = CVRFPARSE::CVRF_parser::new

      results = parser.parse(document, parsables, namespace)
    end

    def print_nodes(nodes, show_namespace, level=0)
      nodes.each do |node|
        print_one_node(node, show_namespace, level + 1)
      end
    end

    def print_one_node(node, show_namespace, level=0)
      length = node.children.length
      if length > 1
        say "#{"\t" * level}[#{node.name.strip}]"
        print_nodes(node.children, show_namespace, level + 1) 
      else
        if show_namespace
          say "#{"\t" * level}[#{node.namespace.href.strip} #{node.name.strip}] #{node.text.strip}" if !node.content.strip.empty?
        else
          say "#{"\t" * level}[#{node.name.strip}] #{node.content.strip}" if !node.content.strip.empty?
        end
      end
    end
  end

end

CvrfParse.start(ARGV)