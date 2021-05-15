with tools;
procedure PetrolStation is
   type pint is access Integer;
   subtype fillingTime is Duration range 2.0..3.0;
   type pfillingTime is access fillingTime;
   type pumps is array(Integer range <>) of Boolean;

   protected Station is
      entry usePumpOne(plate : Integer);
      entry usePumpTwo(plate : Integer);
      entry usePumpThree(plate : Integer);
      entry freePump(pumpNumber : Positive);
      function hasEmptyPump return Boolean;
      function getRandomEmptyPump return Positive;
      function countFreePumps return Natural;
   private
        myPumps : pumps(1..3) :=  (others => True ); --all pumps are empty
   end Station;

   protected body Station is
      entry usePumpOne(plate : Integer) when myPumps(1) is
      begin
         tools.Output.Puts("Car " & Integer'Image(plate) & " served by pump One", 1);
         myPumps(1) := False;
      end usePumpOne;
      entry usePumpTwo(plate : Integer) when myPumps(2) is
      begin
         tools.Output.Puts("Car " & Integer'Image(plate) & " served by pump two", 1);
         myPumps(2) := False;
      end usePumpTwo;
      entry usePumpThree(plate : Integer) when myPumps(3)  is
      begin
         tools.Output.Puts("Car " & Integer'Image(plate) & " served by pump three", 1);
         myPumps(3) := False;
      end usePumpThree;
      entry freePump(pumpNumber : Positive) when True is
      begin
         myPumps(pumpNumber) := True;
      end freePump;

      function hasEmptyPump return Boolean is
      begin
         return countFreePumps /= 0;
      end hasEmptyPump;
      function countFreePumps return Natural is
         count :  Natural := 0;
         begin
         for i in 1..3 loop
            if myPumps(i) = True then
               count := count + 1;
            end if;
         end loop;
         return count;
      end countFreePumps;

      function getRandomEmptyPump return Positive is
          type arr is array(Positive range <>) of Positive;
          available_pumps : arr(1..countFreePumps);
          subtype countPumps is Positive range 1..countFreePumps;
         package pump_gen is new tools.Random_Generator(countPumps);
         count : Positive := 1;
      begin
         for i in 1..3 loop
            if myPumps(i) = True then
               available_pumps(count) := i;
               count := count + 1;
            end if;
         end loop;
         return available_pumps(pump_gen.GetRandom);
      end getRandomEmptyPump;


   end Station;

   task type car(noPlate : pint; fillT : pfillingTime);

   task body car is
      trials : Natural := 0;
      served : Boolean := False;
      subtype pumpCount is Positive range 1..3;
      chosenPump : pumpCount;
   begin
      while trials < 3 loop
         if Station.hasEmptyPump then
            chosenPump := Station.getRandomEmptyPump;
            case chosenPump is
               when 1 =>
                  Station.usePumpOne(noPlate.all);
                  delay fillT.all;
                  Station.freePump(1);
                  served := True;
                  exit;
               when 2 =>
                  Station.usePumpTwo(noPlate.all);
                  delay fillT.all;
                  Station.freePump(2);
                  served := True;
                  exit;
               when 3 =>
                  Station.usePumpThree(noPlate.all);
                  delay fillT.all;
                  Station.freePump(3);
                  served := True;
                  exit;
            end case;
         else
            delay 1.0;
         end if;
         trials := trials + 1;
      end loop;
      if not served then
         tools.Output.Puts("Car " & Integer'Image(noPlate.all) & " Not served by station", 1);
      end if;

   end car;
      type pcar is access car;
      newCar : pcar;
      subtype arrivalTime is Positive range 1..11;
      subtype filltime is Positive range 20..30;
      package arr_time_gen is new tools.Random_Generator(arrivalTime);
      package fill_time_gen is new tools.Random_Generator(filltime);

      begin
         for i in 1..20 loop
             newCar := new car( new Integer'(i), new fillingTime'( Duration( Float(fill_time_gen.GetRandom ) / 10.0 ) ) );
             delay Duration(Float( arr_time_gen.GetRandom )/ 10.0 );
         end loop;

end PetrolStation;
