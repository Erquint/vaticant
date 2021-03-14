require '/lib/array_median.rb'

module Giatros
  module Frametimer
    def self.frametime_raw
      return @@frametimes.last
    end
    
    def self.frametime
      return @@frametime
    end
    
    def self.fps
      return 1 / @@frametime
    end
    
    def self.frametime_label
      return {
        y: $gtk.args.grid.top,
        r: 255,
        text: "%.0f ms/f" % (@@frametime * 1000)
      }
    end
    
    def self.fps_label
      return {
        y: $gtk.args.grid.top - 20,
        r: 255,
        text: "%.0f FPS" % (1 / @@frametime)
      }
    end
    
    def self.graph
      rt = $gtk.args.render_target(:graph)
      rt.w = @@clock_window
      rt.h = 100
      rt.lines << @@frametimes.each_cons(2).each_with_index.map do |a, i|
        {
          x: i,
          y: (a[0] * 1000).clamp(1, rt.h),
          x2: i + 1,
          y2: (a[1] * 1000).clamp(1, rt.h),
          r: 255
        }
      end <<
        {
          x: 1,
          y: 1,
          x2: @@frametimes.length - 1,
          y2: 1,
          r: 255,
          g: 255
        }
      return @@sprite
    end
    
    def self.clock_window
      return @@clock_window
    end
    
    def self.clock_window= framecount
      return @@clock_window = framecount
    end
    
    @@timestamp = Time.now
    @@frametime = 0.016
    @@frametimes = [@@frametime]
    @@clock_window = 60
    @@sprite =
      {
        x: 0,
        y: $gtk.args.grid.h - 140,
        w: 60,
        h: 100,
        path: :graph
      }
    
    module Frametimer_tick
      def tick args
        Frametimer.class_variable_get(:@@frametimes) <<
          Time.now - Frametimer.class_variable_get(:@@timestamp)
        Frametimer.class_variable_set(:@@timestamp, Time.now)
        
        offset = Frametimer.class_variable_get(:@@frametimes).length -
          Frametimer.class_variable_get(:@@clock_window)
        offset.times{Frametimer.class_variable_get(:@@frametimes).shift}
        
        Frametimer.class_variable_set(:@@frametime,
          Frametimer.class_variable_get(:@@frametimes).median)
        super
      end
    end
    GTK::Runtime.prepend Frametimer_tick
  end
end