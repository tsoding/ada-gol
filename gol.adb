with Ada.Text_IO;
with Ada.Characters.Latin_1; -- There's also 'with ASCII;', but that's obsolete
with Ada.Strings.Fixed;

procedure Gol is
    use Ada.Text_IO;

    Width  : constant Positive := 5;
    Height : constant Positive := 5;

    type Cell is (Dead, Alive);
    type Rows is mod Height;
    type Cols is mod Width;
    type Board is array (Rows, Cols) of Cell;
    type Neighbors is range 0 .. 8;

    procedure Render_Board(B: Board) is
    begin
        for Row in Rows loop
            for Col in Cols loop
                case B(Row, Col) is
                    when Alive => Put('#');
                    when Dead  => Put('.');
                end case;
            end loop;
            New_Line;
        end loop;
    end;

    function Count_Neighbors(B: Board; Row0: Rows; Col0: Cols) return Neighbors is
    begin
        return Result : Neighbors := 0 do
            for Delta_Row in Rows range 0 .. 2 loop
                for Delta_Col in Cols range 0 .. 2 loop
                    if Delta_Row /= 1 or Delta_Col /= 1 then
                        declare
                            Row : constant Rows := Row0 + Delta_Row - 1;
                            Col : constant Cols := Col0 + Delta_Col - 1;
                        begin
                            if B(Row, Col) = Alive then
                                Result := Result + 1;
                            end if;
                        end;
                    end if;
                end loop;
            end loop;
        end return;
    end;

    function Next(Current : Board) return Board is
    begin
        return Result : Board do
            for Row in Rows loop
                for Col in Cols loop
                    declare
                        N : constant Neighbors := Count_Neighbors(Current, Row, Col);
                    begin
                        case Current(Row, Col) is
                            when Dead  => 
                                Result(Row, Col) := (if N = 3 then Alive else Dead);
                            when Alive => 
                                Result(Row, Col) := (if N in 2 .. 3 then Alive else Dead);
                        end case; 
                    end;
                end loop;
            end loop;
        end return;
    end;

    Current : Board := (
        ( Dead, Alive,  Dead, others => Dead), 
        ( Dead,  Dead, Alive, others => Dead), 
        (Alive, Alive, Alive, others => Dead), 
        others => (others => Dead) 
    );
begin
    --for I in 1 .. 2 
    loop
        Render_Board(Current);
        Current := Next(Current);
        delay Duration(0.25);
	Put(Ada.Characters.Latin_1.ESC & "[" & Ada.Strings.Fixed.Trim(Height'Image, Ada.Strings.Left) & "A");
        Put(Ada.Characters.Latin_1.ESC & "[" & Ada.Strings.Fixed.Trim(Width'Image, Ada.Strings.Left) & "D");
    end loop;
end;
