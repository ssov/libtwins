require 'mechanize'

module LibTwins
  TWINS_URL="https://twins.tsukuba.ac.jp/campusweb/"
  class LibTwins
    class Course
      class Lecture
        attr_accessor :id, :title, :teacher

        def initialize(**args)
          args.each do |k, v|
            self.instance_variable_set("@#{k}".to_sym, v)
          end
        end
      end

      class RegistrationStatus
        def initialize(session)
          @session = session
          @schedules = []
        end

        def registration(id)
          left_menu = @session.frame_with(name: "menu").click
          page = left_menu.form_with(name: "MenuForm") do |form|
            form.subsysid = "F350"
            form.action = "/campusweb/campussquare.do#F350"
          end.submit
          .form_with(name: "linkForm") do |form|
            form._flowId = "RSW0001000-flow"
          end.submit
          .form_with(name: "InputForm") do |form|
            form.yobi = "9"
            form.jigen = "0"
          end.submit
          .form_with(name: "InputForm") do |form|
            form.jikanwariCode = id
            form._eventId = "insert"
          end.submit

          unless page.search(".error").first.nil?
            puts page.search(".error").first.text.toutf8
            puts page.search("body/p")[1].text.split(/\r\n/)
                     .map{|i| i.gsub(" ", "")}.select{|i| not i.empty?}
                     .join("\n").toutf8
          end
          binding.pry
        end

        def status
          left_menu = @session.frame_with(name: "menu").click
          page = left_menu.form_with(name: "MenuForm") do |form|
            form.subsysid = "F350"
            form.action = "/campusweb/campussquare.do#F350"
          end.submit
          .form_with(name: "linkForm") do |form|
            form._flowId = "RSW0001000-flow"
          end.submit

          week = %w(Mon Tue Wed Thu Fri Sat Sun Etc)
          schedules = week.map{|i| { day: i, classes: [] } }
          (2..7).each do |i|
            (1..7).each do |j|
              res = page.search("table.rishu-koma/tr[#{i}]/td")[j].text
                .split(/\r\n/).map{|k| k.gsub(' ', '')}
                .select{|k| not k.empty?}
              lecture = Course::Lecture.new(
                     id: res[0],
                  title: res[1],
                teacher: res[2]
              )
              schedules[j-1][:classes][i-2] = lecture
            end
          end

          etc = page.search("table.rishu-etc[1]")[0].search("tr")
          (2..etc.size-1).each do |i|
            res = etc[i].text.split(/\r\n/).map{|i| i.gsub(' ', '')}.select{|i| not i.empty?}
            lecture = Course::Lecture.new(
                   id: res[2],
                title: res[3],
              teacher: res[4]
            )
            schedules.last[:classes] << lecture
          end
          @schedules = schedules
        end

        def csv
          left_menu = @session.frame_with(name: "menu").click
          csv = left_menu.form_with(name: "MenuForm") do |form|
            form.subsysid = "F350"
            form.action = "/campusweb/campussquare.do#F350"
          end.submit
          .form_with(name: "linkForm") do |form|
            form._flowId = "RSW0001000-flow"
          end.submit
          .form_with(name: "OutputForm") do |form|
          end.submit
          .form_with(name: "OutputForm") do |form|
            form._eventId = "output"
            form.radiobuttons_with(name: 'outputType', value: 'csv').first.check
            form.radiobuttons_with(name: 'fileEncoding', value: 'UTF8').first.check
          end.submit
        end
      end

      def initialize(session)
        @session = session
      end

      def registration_status
        RegistrationStatus.new(@session)
      end
    end

    def initialize(&block)
      instance_eval(&block)
    end

    def id(id)
      @id = id
    end

    def password(password)
      @password = password
    end

    def login
      agent = Mechanize.new
      page = agent.get(TWINS_URL)
      @session = page.form_with(name: 'form') do |form|
        form.field_with(name: 'userName').value = @id
        form.field_with(name: 'password').value = @password
      end.submit

      unless @session.search(".error").first.nil?
        false
      else
        true
      end
    end

    def course
      Course.new(@session)
    end
  end
end
