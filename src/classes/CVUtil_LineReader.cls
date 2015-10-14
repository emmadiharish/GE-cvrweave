/**
 * Utility class to iterate over lines
 **/

public class CVUtil_LineReader 
    implements Iterator<string>, Iterable<string>
{       
    private String LINE_SEPARATOR = '\r';

    private String textData;

    public CVUtil_LineReader(String textData)
    {       
        this.textData = textData;
    }

    public Boolean hasNext()
    {
        return textData.length() > 0 ? true : false;
    }   

    public String next()
    {
        String row = null;
		Integer endPos = textData.indexOf(LINE_SEPARATOR);
        System.debug(']]]] endPos' + endPos);
/*
       Integer endPos2 = textData.indexOfChar(10);
        System.debug(']]]] endPos2' + endPos2);
        Integer endPos3 = textData.indexOf('\r\n');
        System.debug(']]]] endPos3' + endPos3);
        Integer endPos4 = textData.indexOf('\n');
        System.debug(']]]] endPos4' + endPos4);
        Integer endPos5 = textData.indexOf('\r');
        System.debug(']]]] endPos5' + endPos5);
*/
        
        if(endPos == -1)
        {
            row = textData;
            textData = '';
        }
        else
        {
            row = textData.subString(0, endPos);
            textData = textData.subString(endPos + LINE_SEPARATOR.length(), textData.length());             
        }
        return row;
    }

    public Iterator<String> Iterator()
    {
        return this;   
    }           
}