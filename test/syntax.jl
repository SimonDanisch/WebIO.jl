using WebIO
import WebIO: JSString, @js

@testset "@js_str" begin
    @test js"x=y".s == "x=y"
    y = 1
    @test js"x=$y".s == "x=\$y"
end



@testset "@js" begin

    @test @js(nothing) == js"null"
    @test @js(x) == js"x"
    @test @js(x.y) == js"x.y"

    x = nothing
    @test @js($x) == js"null"

    @test @js(begin
        x
        y
    end) == js"x; y"

    #@test @js(x[]) == js"x[]"
    @test @js(x[1]) == js"x[1]"
    @test @js(x["a"]) == js"x[\"a\"]"
    @test @js(x[1,"a"]) == js"x[1,\"a\"]"


    @test @js(d(x=1)) == js"{x:1}" # special dict syntax
    @test @js(d("x\"y"=1)) == JSString("{\"x\\\"y\":1}")
    @test @js([1, "xyz"]) == js"[1,\"xyz\"]"

    @test @js(1==2) == js"1==2" # special in that it's not wrapped in ()

    @test @js(f()) == js"f()"
    @test @js(f(x)) == js"f(x)"
    @test @js(f(x,y)) == js"f(x,y)"
    @test @js(1+2) == js"(1+2)"

    @test @js(x=1) == js"x=1"

    @test @js(x->x) == js"(function (x){return x})"
    @test @js(x->begin x
              return end) == js"(function (x){x; return })"
    @test @js(x->(1; return x+1)) == js"(function (x){1; return (x+1)})"
    @test @js(function (x) x+1; end) == js"(function (x){return (x+1)})"

    @test @js(@new F()) == js"new F()"
    @test @js(@var x=1) == js"var x=1"

    @test @js(if x; y end) == js"x ? (y) : undefined"
    @test @js(if x; y; else z; end) == js"x ? (y) : (z)"
    @test @js(if x; y; y+1; else z; end) == js"x ? (y, (y+1)) : (z)"
    @test_throws ErrorException @js(if b; @var x=1; x end)

    @test @js(begin
        @var acc = 0
        for i = 1:10
            acc += 1
        end
    end) == js"var acc=0; for(var i = 1; i <= 10; i = i + 1){acc+=1}"

    @test @js(begin
        @var acc = 0
        for i = 1:2:10
            acc += 1
        end
    end) == js"var acc=0; for(var i = 1; i <= 10; i = i + 2){acc+=1}"
end


@testset "@dom_str" begin
    @test props(dom"div#id1"())[:id] == "id1"
    @test props(dom"div.x"())[:className] == ["x"]
    @test props(dom"div.x.y"())[:className] == ["x", "y"]
    @test props(dom"div[x=1]"())[:attributes] == Dict("x" => "1")

    # combination
    n = dom"div#i.x.y[a=b]"("x", prop="x")
    @test props(n)[:attributes] == Dict("a" => "b")
    @test props(n)[:className] == ["x", "y"]
    @test props(n)[:id] == "i"

    # dots in props area
    n = dom"img[src=$im.jpg]"()
    @test !haskey(props(n), :className)
end
