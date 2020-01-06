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
        return distanceSqr(a.x,a.y,b.x,b.y)<(a.radius+b.radius)*(a.radius+b.radius);
    }

    Entity collisionwithWallOccured(Entity item)
    {
        // the X coordinate (0 to 799)
        // the Y coordinate (0 to 514)
        if(item.x-item.radius<0 || item.x+item.radius>514)
            item.vx=-item.vx;
        if(item.y-item.radius<0 || item.y+item.radius>514)
            item.vy=-item.vy;

        return item;
    }

    void ProcessCollision(Entity a, Entity b){
        if(a.radius>b.radius)
        {
            a.radius = sqrt(a.radius*a.radius+b.radius*b.radius);
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

        int j=1;
        while (j<world.entities.length)
        {
            for(int i=0;i< world.entities.length;i++)
            {
                if(isCollisionOccured(world.entities[i], world.entities[j]))
                {
                    if(world.entities[i].radius>world.entities[j].radius)
                    {
                        world.entities[i].radius = sqrt(world.entities[i].radius*world.entities[i].radius+ 
                            world.entities[j].radius*world.entities[j].radius);
                        world.entities[j].radius = 0;
                    }
                    else
                    {
                        world.entities[j].radius = sqrt(world.entities[i].radius*world.entities[i].radius+ 
                            world.entities[j].radius*world.entities[j].radius);
                        world.entities[i].radius = 0;
                    }
                }
            }
            j++;
        }
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

void main()
{
    int playerId = readln.strip.to!int; // your id (0 to 4)

    GameWorld world = new GameWorld(playerId);
    int tick = 0;
    // game loop
    while (1) {
        world.update();
        Simulation sim = new Simulation(world);
        stderr.writeln("simul");
        for (int i = 0; i < 10; i++) {
            sim.computeTick(i);
            //for (int j = 0; j < sim.world.entities.length; j++) {
                stderr.writeln(sim.world.entities[0].to!string);
                
                //Entity enemy = find(my_entities[i], entities, entityCount);
                // Write an action using writeln().
                // To debug: stderr.writeln("Debug messages...");


                // One instruction per chip: 2 real numbers (x y) for a propulsion, or 'WAIT'.
                //writeln(to!string(enemy.x)~to!string(" ")~to!string(enemy.y));
                //writeln("WAIT");
           // }
        }
        for (int i = 0; i < world.myChipCount; i++) {
            
            //Entity enemy = find(my_entities[i], entities, entityCount);
            // Write an action using writeln().
            // To debug: stderr.writeln("Debug messages...");


            // One instruction per chip: 2 real numbers (x y) for a propulsion, or 'WAIT'.
            //writeln(to!string(enemy.x)~to!string(" ")~to!string(enemy.y));
            if(tick == 0)
                writeln("0 0");
            else writeln("WAIT");
        }
        tick++;
    }
}
