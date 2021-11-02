# Interface javax.jms.MapMessage
module JMS::MapMessage
  # Since each is defined, add support for: inject, map, include?, and find_all?
  # <=> also allows support for:  min, max, and sort
  include Enumerable

  # Return Map Message as a hash
  def to_h
    h = {}
    each_pair { |key, value| h[key] = value }
    h
  end

  # Return Map Message as a hash
  def data
    to_h
  end

  # Copy values from supplied hash into this MapMessage
  # Converts Ruby types to Java native Data types as follows:
  #   Integer  => long
  #   Float    => double
  #   true     => boolean
  #   false    => boolean
  #   nil      => null
  #   Otherwise it calls ::to_s on the supplied data type
  def data=(data)
    data.each_pair do |key, val|
      case val
      when Integer # 1 or 11111111111111111 (Bignum)
        setLong(key.to_s, val)
      when Float # 1.1
        setDouble(key.to_s, val)
      when true, false
        setBoolean(key.to_s, val)
      when nil
        setObject(key.to_s, val)
      else
        setString(key.to_s, val.to_s)
      end
    end
  end

  # Return each name value pair
  def each(&proc)
    # When key and value are expected separately. Should actually be calling each_pair anyway
    if proc.arity == 2
      each_pair(proc)
    else
      enum = getMapNames
      while enum.has_more_elements
        key = enum.next_element
        proc.call [key, getObject(key)]
      end
    end
  end

  # Return each name value pair
  def each_pair(&proc)
    enum = getMapNames
    while enum.has_more_elements
      key = enum.next_element
      proc.call key, getObject(key)
    end
  end

  # Does map include specified key
  def include?(key)
    # Ensure a Ruby true is returned
    item_exists(key) == true
  end
end
