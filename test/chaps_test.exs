defmodule ChapsTest do
  use ExUnit.Case
  import Mock

  @stats "dummy stats"

  test_with_mock "analyze local", Chaps.Local, execute: fn _, _ -> nil end do
    Chaps.analyze(@stats, "local", [])
    assert called(Chaps.Local.execute(@stats, []))
  end

  test_with_mock "analyze html", Chaps.Html, execute: fn _, _ -> nil end do
    Chaps.analyze(@stats, "html", [])
    assert called(Chaps.Html.execute(@stats, []))
  end

  test_with_mock "analyze json", Chaps.Json, execute: fn _, _ -> nil end do
    Chaps.analyze(@stats, "json", [])
    assert called(Chaps.Json.execute(@stats, []))
  end

  test "analyze undefined type" do
    assert_raise RuntimeError, fn ->
      Chaps.analyze(@stats, "Undefined Type", [])
    end
  end
end
