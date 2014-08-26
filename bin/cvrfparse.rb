require 'thor'
require 'cvrfparse'

class CvrfParse < Thor

  desc 'parse [DOCUMENT]', 'parse an CVRF document'
  method_option :namespace, :type => :string, :required => true
  method_option :parsables, :type => :array, :required => true
  method_option :show_namespace, :type => :boolean, :default => false
  def parse(document)
    parser = CVRFPARSE::CVRF_parser::new

    namespace = options[:namespace].to_sym

    results = parser.parse(document, options[:parsables], namespace)

    results.each do |r|
      if options[:show_namespace]
        puts "[#{r[:namespace]} #{r[:name]}] #{r[:text]}"
      else
        puts "[#{r[:name]}] #{r[:text]}"
      end
    end
  end

  desc 'validate [DOCUMENT]', 'validate an CVRF document'
  method_option :schema, :type => :string
  def validate(document)
    parser = CVRFPARSE::CVRF_parser::new
    schema = options[:schema]

    result = (schema.nil?) ? parser.validate(document) : parser.validate(document, schema)

    if result.empty?
      puts 'Valid'
    else
      puts 'Invalid'
      result.each do |error|
        puts error
      end
    end
  end

end

CvrfParse.start(ARGV)