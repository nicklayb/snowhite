defmodule Snowhite.Helpers.CasingTest do
  use Snowhite.TestCase

  alias Snowhite.Helpers.CalendarBuilder

  describe "build_month/1" do
    @input_date ~D[2020-09-15]
    @expected [
      [
        ~D[2020-08-30],
        ~D[2020-08-31],
        ~D[2020-09-01],
        ~D[2020-09-02],
        ~D[2020-09-03],
        ~D[2020-09-04],
        ~D[2020-09-05]
      ],
      [
        ~D[2020-09-06],
        ~D[2020-09-07],
        ~D[2020-09-08],
        ~D[2020-09-09],
        ~D[2020-09-10],
        ~D[2020-09-11],
        ~D[2020-09-12]
      ],
      [
        ~D[2020-09-13],
        ~D[2020-09-14],
        ~D[2020-09-15],
        ~D[2020-09-16],
        ~D[2020-09-17],
        ~D[2020-09-18],
        ~D[2020-09-19]
      ],
      [
        ~D[2020-09-20],
        ~D[2020-09-21],
        ~D[2020-09-22],
        ~D[2020-09-23],
        ~D[2020-09-24],
        ~D[2020-09-25],
        ~D[2020-09-26]
      ],
      [
        ~D[2020-09-27],
        ~D[2020-09-28],
        ~D[2020-09-29],
        ~D[2020-09-30],
        ~D[2020-10-01],
        ~D[2020-10-02],
        ~D[2020-10-03]
      ]
    ]
    test "should build a month for a given date" do
      assert @expected == CalendarBuilder.build_month(@input_date)
    end
  end
end
