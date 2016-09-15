import org.jsoup.nodes.Document;
import org.jsoup.Jsoup;
import org.jsoup.select.Elements;

import java.io.IOException;

/**
 * Created by MarkSchatzman on 9/14/16.
 */
public class Scraper {
    public static void main(String[] args) throws IOException{
        Document document = Jsoup.connect("https://www.opensecrets.org/").userAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36").get();

        Elements links = document.select("a[href");
        Elements media = document.select("[src]");
        Elements imports = document.select("link[href]");

        System.out.println("Links: " + links.size());
        System.out.println("Media: " + media.size());
        System.out.println("Imports: " + imports.size());

    }
}
