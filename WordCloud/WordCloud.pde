String[] allBookWords; //array containing all words in the book
String[] sampleWords; //array containing sample words from allWords
int[] textSizes; //array for the text size
int[] textHeights; //array for the height of each word
int[] textWidths; //array for the width of each word
float[] x; //array containing all x of each word
float[] y; //array containing all y of each word
final String FILE_NAME = "alice_just_text.txt"; //file name of the book
final int SCREEN_WIDTH = 800; //width of the screen
final int SCREEN_HEIGHT = 800; //height of the screen
final int SAMPLE_SIZE = 100; //size of the sample words
final int MAX_TEXT_SIZE = 105; //max size of the font
final int INTERVAL = 100;
final float JITTER = 1; // the value of the JITTER is 1

void setup(){
  //read the book file and store the words in a global array
  allBookWords = loadBookIntoStringArray(FILE_NAME);
  //get the sampled words, store them in a global array
  sampleWords = sample(allBookWords, SAMPLE_SIZE);
  //pre-calculate the WIDTH, HEIGHT and SIZE of each word
  textSizes = new int[SAMPLE_SIZE];
  textHeights = new int[SAMPLE_SIZE];
  textWidths = new int[SAMPLE_SIZE];
  for(int i=0;i<SAMPLE_SIZE;i++){
    textSizes[i] = int(MAX_TEXT_SIZE / sqrt(i+1));
    textHeights[i] = textSizes[i];
    textAlign(CENTER,CENTER);
    textSize(textSizes[i]);
    textWidths[i] = int(textWidth(sampleWords[i]));
  }
  //pre-calculate each word’s starting point
  x = new float[SAMPLE_SIZE];
  y = new float[SAMPLE_SIZE];
  x[0] = SCREEN_WIDTH/2 + INTERVAL;
  y[0] = SCREEN_HEIGHT/2 + INTERVAL;
  for(int i=1;i<SAMPLE_SIZE;i++){
    float jitterForX = random(-JITTER,JITTER);
    float jitterForY = random(-JITTER,JITTER);
    x[i] = INTERVAL + SCREEN_WIDTH/2 * (1 + jitterForX);
    y[i] = INTERVAL + SCREEN_HEIGHT/2 * (1 + jitterForY);
  }
  //init the frame
  size(1000,1000);
}

void draw(){
  clear();
  drawWordCloud();
}

String[] loadBookIntoStringArray(String bookFileName){
  //load the file and join the lines into a single String
  String bookWordsString = join(loadStrings(bookFileName)," ");
  
  //use the split method to tokenize the string using whitespace and 
  //non-word delimiters. Return the result.
  return bookWordsString.split("[\\s\\W]+"); 
}

float[] avgOverlap(int pos){
  float avgX = 0;
  float avgY = 0;
  int num = 0;
  for(int i=0;i<SAMPLE_SIZE;i++){
    float absX = abs(x[pos] - x[i]);
    float absY = abs(y[pos] - y[i]);
    int minX = textWidths[pos]/2 + textWidths[i]/2;
    int minY = textHeights[pos]/2 + textHeights[i]/2;
    if(absX < minX && absY < minY){
        avgX += x[i];
        avgY += y[i];
        num++;
    }
  }
  float[] result = new float[2];
  result[0] = avgX / num;
  result[1] = avgY / num;
  return result;
}

void drawWordCloud(){
    for(int i=0;i<SAMPLE_SIZE;i++){
      if(i != 0){
        float[] centroid = avgOverlap(i);
        float diffX = x[i] - centroid[0];
        float diffY = y[i] - centroid[1];
        if(diffX != 0 || diffY != 0){
          float totalDistance = sqrt(diffX * diffX + diffY * diffY);
          x[i] += diffX / totalDistance;
          y[i] += diffY / totalDistance;
          float jitterForX = random(-JITTER,JITTER);
          float jitterForY = random(-JITTER,JITTER);
          x[i] = INTERVAL + (x[i] - INTERVAL) * (1 + jitterForX);
          y[i] = INTERVAL + (y[i] - INTERVAL) * (1 + jitterForY);
        }
      }
      //Make sure the word does not go oF the screen
      if(x[i] < INTERVAL || x[i] > INTERVAL + SCREEN_WIDTH)
        x[i] = INTERVAL + SCREEN_WIDTH/2 * (1 + random(-JITTER,JITTER));
      if(y[i] < INTERVAL || y[i] > INTERVAL + SCREEN_HEIGHT)
        y[i] = INTERVAL + SCREEN_HEIGHT/2 * (1 + random(-JITTER,JITTER));
      //plot the text
      textAlign(CENTER,CENTER);
      textSize(textSizes[i]);
      text(sampleWords[i],x[i],y[i]);
    }
}

int find(String word, String[] words, int start, int stop){
  for(int i=start;i<stop;i++){
    if(words[i].equals(word))
      return i;
  }
  return -1;
}

String[] sample(String[] words, int numToPlot){
  String[] sampleWords = new String[numToPlot];
  for(int i=0;i<numToPlot;i++){
    while(true){
      int randomWordIndex = int(random(0,words.length));
      String randomWord = words[randomWordIndex];
      if(randomWord.length() >= 3 && find(randomWord,sampleWords,0,i) == -1){
        sampleWords[i] = randomWord;
        break;
      }
    }
  }
  return sampleWords;
}