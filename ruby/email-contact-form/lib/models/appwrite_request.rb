class AppwriteRequest
    attr_reader :method, :headers, :body, :path
  
    def initialize(context)
      @method = context['req']['method']
      @headers = context['req']['headers']
      @body = context['req']['body']
      @path = context['req']['path'] || '/'
    end
  end