require 'simplecov'
require 'rspec'
require 'cvrfparse'

describe 'Cvrfparse' do
  before(:each) do
    @parser = CVRFPARSE::CvrfParser.new
    @schema_local = File.dirname(__FILE__) + '/schemadata/cvrf/1.1/cvrf.xsd'
    @document_valid = File.dirname(__FILE__) +
              '/sample-xml/CVRF-1.1-cisco-sa-20110525-rvs4000.xml'
    @document_invalid = File.dirname(__FILE__) +
              '/sample-xml/CVRF-1.1-cisco-sa-20110525-rvs4000-invalid.xml'
    @document_notwellformed = File.dirname(__FILE__) +
              '/sample-xml/CVRF-1.1-cisco-sa-20110525-rvs4000-notwellformed.xml'
  end

  describe 'valid' do
    it 'validate' do
      expect(@parser.validate(@document_valid)).to be_empty
    end

    it 'validate local' do
      expect(@parser.validate(@document_valid, @schema_local)).to be_empty
    end

    describe 'parse' do
      describe 'CVRF' do
        before(:each) { @namespace = :cvrf }
        it 'parse for DocumentTitle must be not empty' do
          parsables = %w(DocumentTitle)
          result = @parser.parse(@document_valid, parsables, @namespace)
          expect(result).not_to be_empty
        end

        it 'parse for DocumentTitle must be named "DocumentTitle"' do
          parsables = %w(DocumentTitle)
          result = @parser.parse(@document_valid, parsables, @namespace)
          expect(result[0].name.strip).to eq('DocumentTitle')
        end

        it 'parse for DocumentTitle must be have namespace "http://www.icasi.org/CVRF/schema/cvrf/1.1"' do
          parsables = %w(DocumentTitle)
          result = @parser.parse(@document_valid, parsables, @namespace)
          expect(result[0].namespace.href.strip).to eq('http://www.icasi.org/CVRF/schema/cvrf/1.1')
        end

        it 'parse for DocumentTitle must be have text "Cisco Security Advisory: Cisco RVS4000 and WRVS4400N Web Management Interface Vulnerabilities"' do
          parsables = %w(DocumentTitle)
          result = @parser.parse(@document_valid, parsables, @namespace)
          expect(result[0].text.strip).to eq('Cisco Security Advisory: Cisco RVS4000 and WRVS4400N Web Management Interface Vulnerabilities')
        end
      end
      describe 'Product' do
        pending
      end
      describe 'Vulnerability' do
        pending
      end
    end
  end

  describe 'invalid' do
    it 'validate' do
      expect(@parser.validate(@document_invalid)).not_to be_empty
    end

    it 'validate local' do
      expect(@parser.validate(@document_invalid, @schema_local)).not_to be_empty
    end
  end

  describe 'not well formed' do
    it 'validate' do
      expect(@parser.validate(@document_notwellformed)).not_to be_empty
    end

    it 'validate local' do
      expect(@parser.validate(@document_notwellformed, @schema_local)).not_to be_empty
    end
  end
end
