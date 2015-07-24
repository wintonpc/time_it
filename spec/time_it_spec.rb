require 'rspec'
require 'time_it'

describe '::time_it' do
  it 'foo' do
    time_it('a') do
      sleep(0.01)
      time_it('b') do
        sleep(0.2)
      end
      sleep(0.1)
      time_it('c') do
        sleep(0.3)
        time_it('d') do
          sleep(0.02)
        end
        100.times.each do
          time_all('e') do
            sleep(0.002)
          end
        end
      end
    end
  end
end
