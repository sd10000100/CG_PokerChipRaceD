import std;

/**
 * It's the survival of the biggest!
 * Propel your chips across a frictionless table top to avoid getting eaten by bigger foes.
 * Aim for smaller oil droplets for an easy size boost.
 * Tip: merging your chips will give you a sizeable advantage.
 **/

 double distanceSqr(float ax,float ay, float bx,float by) {
            return (ax - bx) * (ax - bx) +
                   (ay - by) * (ay - by);
        }

class Entity {
    int id;
    int playerId;
    float radius;
    float x;
    float y;
    float vx;
    float vy;

    this(int id,
    int playerId,
    float radius,
    float x,
    float y,
    float vx,
    float vy){
        this.id = id;
        this.playerId=playerId;
        this.radius = radius;
        this.x=x;
        this.y=y;
        this.vx=vx;
        this.vy=vy;
    }

    override string toString() const {
        return "Entity" ~ "(" ~
            "id:" ~ to!string(id) ~
            " playerId:" ~ to!string(playerId) ~
            " radius:" ~ to!string(radius) ~
            " x:" ~ to!string(x) ~
            " y:" ~ to!string(y) ~
            " vx:" ~ to!string(vx) ~
            " vy:" ~ to!string(vy) ~
            ")";
    }
    
}

class GameWorld{
    int myId;
    int myChipCount;
    Entity[] entities;
    Entity[] myEntities;
    Entity[] enemyEntities;
    Entity[] oilEntities;
    this(int myId){
        this.myId = myId;
    }

    void update(){
        
        int playerChipCount = readln.strip.to!int; // The number of chips under your control
        this.myChipCount = playerChipCount;
        int entityCount = readln.strip.to!int; // The total number of entities on the table, including your chips        
        this.entities = new Entity[entityCount];
        
        this.myEntities = new Entity[myChipCount];
        this.enemyEntities = new Entity[entityCount - myChipCount];
        this.oilEntities = new Entity[entityCount - myChipCount];
        
        int myIndex = 0;
        int enemyIndex = 0;
        int oilIndex = 0;
        
        for (int i = 0; i < entityCount; i++) {
            auto inputs = readln.split;
            int id = inputs[0].to!int; // Unique identifier for this entity
            int player = inputs[1].to!int; // The owner of this entity (-1 for neutral droplets)
            float radius = inputs[2].to!float; // the radius of this entity
            float x = inputs[3].to!float; // the X coordinate (0 to 799)
            float y = inputs[4].to!float; // the Y coordinate (0 to 514)
            float vx = inputs[5].to!float; // the speed of this entity along the X axis
            float vy = inputs[6].to!float; // the speed of this entity along the Y axis
            entities[i] = new Entity(id,player,radius,x,y,vx,vy);
            
            if(id==0){
                stderr.writeln("world");
                stderr.writeln(entities[i].to!string);
            }
           // stderr.writeln(entities[i].to!string);
            if(player==this.myId)
            {
                myEntities[myIndex] = entities[i];
                myIndex++;
            }
            else if(player==-1)
            {
                oilEntities[oilIndex] = entities[i];
                oilIndex++;
            }
            else 
            {
                enemyEntities[enemyIndex] = entities[i];
                enemyIndex++;
            }
        }
    }
    /*
    Entity[] getMyEntities()
    {
        Entity[] myEntities = new Entity[myChipCount];
        int index = 0;
        for (int i = 0; i < entities.length; i++) {
            if(entities[i].playerId == myId)
            {
                myEntities[index]= entities[i];
                index ++;
            }
                
        }
        return myEntities;
    }

    Entity[] getEnemyEntities()
    {
        Entity[] enemyEntities = new Entity[entities.length - myChipCount];
        int index = 0;
        for (int i = 0; i < entities.length; i++) {
            if(entities[i].playerId != myId)
            {
                enemyEntities[index]= entities[i];
                index ++;
            }
                
        }
        return enemyEntities;
    }

    Entity[] getOilEntities()
    {
        Entity[] enemyEntities = new Entity[entities.length - myChipCount];
        int index = 0;
        for (int i = 0; i < entities.length; i++) {
            if(entities[i].playerId != myId)
            {
                enemyEntities[index]= entities[i];
                index ++;
            }
                
        }
        return enemyEntities;
    }
    */
}

class Simulation{
    int currentTick = 0;
    GameWorld world;
    

    this(GameWorld initWorld){
        world = initWorld;//[0: initWorld];
        currentTick++;
    }

    bool isCollisionOccured(Entity a, Entity b)
    {
        if(b.radius!=0)
            return distanceSqr(a.x,a.y,b.x,b.y)<(a.radius+b.radius)*(a.radius+b.radius);
        return false;
    }   

    Entity collisionwithWallOccured(Entity item)
    {
        // the X coordinate (0 to 799)
        // the Y coordinate (0 to 514)
        // if(item.x-item.radius<0 || item.x+item.radius>514)
        //     item.vx=-item.vx;
        // if(item.y-item.radius<0 || item.y+item.radius>514)
        //     item.vy=-item.vy;
        if(item.x-item.radius<0 ) item.vx=abs(item.vx);
        if(item.x+item.radius>799 ) item.vx=-abs(item.vx);
        
        if(item.y-item.radius<0 ) item.vy=abs(item.vy);
        if(item.y+item.radius>514 ) item.vy=-abs(item.vy);

        return item;
    }

    void ProcessCollision(Entity a, Entity b){
        if(a.radius>b.radius)
        {
            double newR = sqrt(a.radius*a.radius+b.radius*b.radius);
            //a.radius = sqrt(a.radius*a.radius+b.radius*b.radius);
            a.x = 
            b.radius = 0;
        }
        else
        {
            b.radius = sqrt(a.radius*a.radius+b.radius*b.radius);
            a.radius = 0;
        }
    }
    Entity updateEntity(int tick, Entity entity){
        entity.x+=entity.vx;
        entity.y+=entity.vy; 
        return entity;
    }
    
    
    
    void computeTick(int tick, int microtickCount=0){
        
        for(int i=0;i< world.entities.length;i++)
        {
            world.entities[i] = updateEntity(tick,world.entities[i]);
            world.entities[i] = collisionwithWallOccured(world.entities[i]);
            
        }

        int j=0;
        while (j<world.entities.length-1)
        {
            for(int i=j+1;i< world.entities.length;i++)
            {
                if(isCollisionOccured(world.entities[i], world.entities[j]))
                {
                    double newR = sqrt(world.entities[i].radius*world.entities[i].radius+ 
                            world.entities[j].radius*world.entities[j].radius);
                    double newVX = (world.entities[i].radius/newR)*world.entities[i].vx
                        +(world.entities[j].radius/newR)*world.entities[j].vx;
                    double newVY = (world.entities[i].radius/newR)*world.entities[i].vy
                        +(world.entities[j].radius/newR)*world.entities[j].vy;
                        
                    
                    if(world.entities[i].radius>world.entities[j].radius)
                    {
                            
                        world.entities[i].radius = newR;
                        world.entities[i].vx = newVX;
                        world.entities[i].vy = newVY;
                        world.entities[j].radius = 0;
                    }
                    else
                    {
                        world.entities[j].radius = newR;
                        world.entities[j].vx = newVX;
                        world.entities[j].vy = newVY;
                        world.entities[i].radius = 0;
                    }
                }
            }
            j++;
        }
    }

    void processWaitCommand(int countTick)
    {
        this.computeTick(countTick);
    }

    void processGoCommand(int idEntity, double x, double y ,int countTick)
    {
        Entity me = null;
        for(int i=0;i< world.entities.length;i++)
        {
            if(idEntity==world.entities[i].id){
                me = world.entities[i];
                break;
                }
        }

        double alfa = atan2(y-me.y,x-me.x);

        me.radius *= sqrt(14.0/15.0);
        
        me.vx +=200*cos(alfa)/14;
        me.vy +=200*sin(alfa)/14;
        for(int tick = 0;tick<countTick;tick++)
        {
            computeTick(tick);
        }
        
    }

    void processGoCommand(int idEntity, double alfa ,int countTick)
    {
        Entity me = null;
        for(int i=0;i< world.entities.length;i++)
        {
            if(idEntity==world.entities[i].id){
                me = world.entities[i];
                break;
            }
        }

        me.radius *= sqrt(14.0/15.0);
        
        me.vx +=200*cos(alfa)/14;
        me.vy +=200*sin(alfa)/14;
        for(int tick = 0;tick<countTick;tick++)
        {
            computeTick(tick);
        }
    }

    double getRadiusById(int idEntity)
    {
        Entity me = null;
        for(int i=0;i< world.entities.length;i++)
        {
            if(idEntity==world.entities[i].id){
                me = world.entities[i];
                break;
            }
        }

        return me.radius;
    }
}



Entity find(Entity my, Entity[] entities, int elemCount){
    float mindist = 10000;
    Entity minEntity;
    for (int i = 0; i < elemCount; i++) {
        if(entities[i].radius<my.radius && distanceSqr(entities[i].x,entities[i].y, my.x,my.y) && entities[i].playerId!=my.playerId)
        {
            mindist = distanceSqr(entities[i].x,entities[i].y, my.x,my.y);
            minEntity = entities[i];
        }
        
    }
    return minEntity;
}

Entity findById(int id, Entity[] entities, int elemCount){
    for (int i = 0; i < elemCount; i++) {
        if(entities[i].id==id)
        {
            return entities[i];
        }
    }
    return null;
}

class Point {
    float x;
    float y;

    this(float x, float y){
        this.x=x;
        this.y=y;
    }
}

Point Turn(Point from, Point to, double angle)
{
    double Vx = to.x - from.x;
    double Vy = to.y - from.y;
    double x = Vx * cos(angle) - Vy * sin(angle);
    double y = Vy * cos(angle) + Vx * sin(angle);
    to.x = from.x + x;
    to.y = from.y + y;

    return to;
}

void main()
{
    int playerId = readln.strip.to!int; // your id (0 to 4)

    GameWorld world = new GameWorld(playerId);
    int tick = 0;
    double pi = 3.14159;
    // game loop
    while (1) {
        world.update();
        
        
        //for (int i = 0; i < 10; i++) {
        //    sim.computeTick(i);
        //    //for (int j = 0; j < sim.world.entities.length; j++) {
        //    stderr.writeln(sim.world.entities[0].to!string);
        //        
        //        //Entity enemy = find(my_entities[i], entities, entityCount);
        //        // Write an action using writeln().
        //        // To debug: stderr.writeln("Debug messages...");
        //
        //
        //        // One instruction per chip: 2 real numbers (x y) for a propulsion, or 'WAIT'.
        //        //writeln(to!string(enemy.x)~to!string(" ")~to!string(enemy.y));
        //        //writeln("WAIT");
        //   // }
        //}
        for (int i = 0; i < world.myChipCount; i++) {
            if(tick == 0 || tick%5==0){
            Simulation sim = new Simulation(world);
            stderr.writeln("simul");
            double[] alfas = new double[8];
            alfas=[0, pi/4, pi/2, 3*pi/4, pi, 5*pi/4, 3*pi/2, 7*pi/4];
            Point newTarget = new Point(0,0);
            double maxRadius =-1; 
            
            Entity me = world.myEntities[i];
            stderr.writeln("current : "~me.radius.to!string);
            foreach(double alfa; alfas)
            {
                
                Point target = Turn(new Point(me.x, me.y), new Point(me.x+me.radius, me.y), alfa);
                sim.processGoCommand(me.id, target.x, target.y ,10);
                if(sim.getRadiusById(me.id)>maxRadius)
                {
                    maxRadius = sim.getRadiusById(me.id);
                    newTarget.x = target.x;
                    newTarget.y = target.y;
                }
            }
            stderr.writeln("progns : "~maxRadius.to!string);
            //Entity enemy = find(my_entities[i], entities, entityCount);
            // Write an action using writeln().
            // To debug: stderr.writeln("Debug messages...");


            // One instruction per chip: 2 real numbers (x y) for a propulsion, or 'WAIT'.
            //writeln(to!string(enemy.x)~to!string(" ")~to!string(enemy.y));
                if(me.radius>maxRadius)
                {
                    sim = new Simulation(world);
                    sim.processWaitCommand(10);
                    double anotherMaxRadius =sim.getRadiusById(me.id); 
                    if(anotherMaxRadius>maxRadius){
                        writeln("WAIT");
                    }
                    else
                        writeln(newTarget.x.to!string~" "~newTarget.y.to!string);
                }
                    writeln(newTarget.x.to!string~" "~newTarget.y.to!string);
            }
            else writeln("WAIT");
        }
        tick++;
    }
}
